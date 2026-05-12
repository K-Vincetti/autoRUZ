using System.Diagnostics;
using System.Text;
using System.Text.Json;
using Npgsql;

var app = new QueueApplication(args);
await app.RunAsync();

internal sealed class QueueApplication
{
    private static readonly string[] TaskTypes =
    [
        "ad_moderation",
        "rating_recalculation",
        "notification_send",
        "ad_indexing"
    ];

    private readonly string[] _args;

    public QueueApplication(string[] args)
    {
        _args = args;
    }

    public async Task RunAsync()
    {
        if (_args.Length == 0)
        {
            PrintUsage();
            return;
        }

        var mode = _args[0].ToLowerInvariant();

        switch (mode)
        {
            case "producer":
                await RunProducerAsync();
                return;
            case "worker":
                await RunWorkerAsync();
                return;
            case "monitor":
                await RunMonitorAsync();
                return;
            case "cleanup":
                await RunCleanupAsync();
                return;
            case "stats":
                await RunStatsAsync();
                return;
            default:
                PrintUsage();
                return;
        }
    }

    private async Task RunProducerAsync()
    {
        var rate = ParseIntOption("--rate", 100);
        if (rate <= 0)
        {
            Console.WriteLine("Rate must be greater than 0.");
            return;
        }

        var connectionString = LoadConnectionString();
        await using var dataSource = NpgsqlDataSource.Create(connectionString);
        await using var connection = await dataSource.OpenConnectionAsync();

        Console.WriteLine($"Producer started. rate={rate}/s");

        long createdTotal = 0;
        long createdNormal = 0;
        long createdCritical = 0;
        var reportSince = Stopwatch.StartNew();
        var ticker = new PeriodicTimer(TimeSpan.FromSeconds(1));

        while (await ticker.WaitForNextTickAsync())
        {
            var batchStartedAt = Stopwatch.StartNew();

            var notifyLogged = false;

            for (var i = 0; i < rate; i++)
            {
                var priority = Random.Shared.Next(100) < 20 ? 100 : 0;
                var businessEventId = await InsertBusinessEventWithTaskAsync(connection, priority);

                _ = businessEventId;

                if (!notifyLogged)
                {
                    Console.WriteLine("NOTIFY task_created sent");
                    notifyLogged = true;
                }

                createdTotal++;
                if (priority == 100)
                {
                    createdCritical++;
                }
                else
                {
                    createdNormal++;
                }
            }

            var elapsed = batchStartedAt.Elapsed.TotalSeconds;
            var actualRate = elapsed > 0 ? Math.Round(rate / elapsed, 2) : rate;

            if (reportSince.Elapsed >= TimeSpan.FromSeconds(1))
            {
                Console.WriteLine(
                    $"created_total={createdTotal} normal={createdNormal} critical={createdCritical} current_rate={actualRate}/s");
                reportSince.Restart();
            }
        }
    }

    private async Task RunWorkerAsync()
    {
        var workerName = TryGetOptionValue("--name");
        if (string.IsNullOrWhiteSpace(workerName))
        {
            Console.WriteLine("Worker name is required. Example: dotnet run -- worker --name worker-1");
            return;
        }

        var failRate = ParseDoubleOption("--fail-rate", 0.1);
        if (failRate is < 0 or > 1)
        {
            Console.WriteLine("Fail rate must be between 0 and 1.");
            return;
        }

        var connectionString = LoadConnectionString();
        await using var dataSource = NpgsqlDataSource.Create(connectionString);
        await using var listenerConnection = await dataSource.OpenConnectionAsync();

        listenerConnection.Notification += (_, e) =>
        {
            Console.WriteLine($"notification received: {e.Channel}");
        };

        await using (var listenCommand = new NpgsqlCommand("LISTEN task_created;", listenerConnection))
        {
            await listenCommand.ExecuteNonQueryAsync();
        }

        Console.WriteLine($"Worker started. name={workerName} fail_rate={failRate:0.##}");
        Console.WriteLine("Listening channel task_created");

        while (true)
        {
            var processed = await TryProcessSingleTaskAsync(dataSource, workerName, failRate);
            if (processed)
            {
                continue;
            }

            using var waitCts = new CancellationTokenSource(TimeSpan.FromSeconds(2));
            try
            {
                await listenerConnection.WaitAsync(waitCts.Token);
            }
            catch (OperationCanceledException)
            {
            }
        }
    }

    private async Task RunMonitorAsync()
    {
        var intervalSeconds = ParseIntOption("--interval", 2);
        if (intervalSeconds <= 0)
        {
            intervalSeconds = 2;
        }

        var connectionString = LoadConnectionString();
        await using var dataSource = NpgsqlDataSource.Create(connectionString);
        Console.WriteLine($"Monitor started. interval={intervalSeconds}s");

        var timer = new PeriodicTimer(TimeSpan.FromSeconds(intervalSeconds));
        while (await timer.WaitForNextTickAsync())
        {
            var snapshot = await LoadMonitorSnapshotAsync(dataSource);
            var lagText = snapshot.QueueLag.HasValue
                ? snapshot.QueueLag.Value.ToString(@"dd\.hh\:mm\:ss")
                : "00.00:00:00";

            Console.WriteLine(
                $"ready_count={snapshot.ReadyCount} running_count={snapshot.RunningCount} completed_count={snapshot.CompletedCount} failed_count={snapshot.FailedCount} queue_lag={lagText} throughput={snapshot.ThroughputPerSecond:0.00}/s completed_p0={snapshot.CompletedPriority0} completed_p100={snapshot.CompletedPriority100}");
        }
    }

    private async Task RunCleanupAsync()
    {
        var connectionString = LoadConnectionString();
        await using var dataSource = NpgsqlDataSource.Create(connectionString);
        await using var connection = await dataSource.OpenConnectionAsync();

        await using var command = new NpgsqlCommand(
            """
            TRUNCATE TABLE queue.tasks RESTART IDENTITY CASCADE;
            TRUNCATE TABLE queue.business_events RESTART IDENTITY CASCADE;
            """,
            connection);

        await command.ExecuteNonQueryAsync();
        Console.WriteLine("Cleanup completed. queue.tasks and queue.business_events were truncated.");
    }

    private async Task RunStatsAsync()
    {
        var connectionString = LoadConnectionString();
        await using var dataSource = NpgsqlDataSource.Create(connectionString);
        var snapshot = await LoadMonitorSnapshotAsync(dataSource);

        Console.WriteLine($"ready_count={snapshot.ReadyCount}");
        Console.WriteLine($"running_count={snapshot.RunningCount}");
        Console.WriteLine($"completed_count={snapshot.CompletedCount}");
        Console.WriteLine($"failed_count={snapshot.FailedCount}");
        Console.WriteLine($"queue_lag={(snapshot.QueueLag.HasValue ? snapshot.QueueLag.Value.ToString(@"dd\.hh\:mm\:ss") : "00.00:00:00")}");
        Console.WriteLine($"throughput={snapshot.ThroughputPerSecond:0.00}/s");
        Console.WriteLine($"completed_priority_0={snapshot.CompletedPriority0}");
        Console.WriteLine($"completed_priority_100={snapshot.CompletedPriority100}");
    }

    private async Task<long> InsertBusinessEventWithTaskAsync(NpgsqlConnection connection, int priority)
    {
        var advertisementId = Random.Shared.NextInt64(1, 1_000_000);
        var taskType = TaskTypes[Random.Shared.Next(TaskTypes.Length)];
        var now = DateTimeOffset.UtcNow;

        var payloadJson = JsonSerializer.Serialize(new
        {
            advertisementId,
            taskType,
            source = "producer",
            createdAtUtc = now,
            priority
        });

        await using var transaction = await connection.BeginTransactionAsync();

        await using var insertBusinessEvent = new NpgsqlCommand(
            """
            INSERT INTO queue.business_events (event_type, advertisement_id, payload, created_at)
            VALUES (@event_type, @advertisement_id, CAST(@payload AS jsonb), now())
            RETURNING id;
            """,
            connection,
            transaction);

        insertBusinessEvent.Parameters.AddWithValue("event_type", taskType);
        insertBusinessEvent.Parameters.AddWithValue("advertisement_id", advertisementId);
        insertBusinessEvent.Parameters.AddWithValue("payload", payloadJson);

        var businessEventId = (long)(await insertBusinessEvent.ExecuteScalarAsync()
                              ?? throw new InvalidOperationException("Failed to insert business event."));

        await using var insertTask = new NpgsqlCommand(
            """
            INSERT INTO queue.tasks (
                business_event_id,
                task_type,
                payload,
                status,
                priority,
                attempts,
                max_attempts,
                scheduled_at,
                created_at
            )
            VALUES (
                @business_event_id,
                @task_type,
                CAST(@payload AS jsonb),
                'Ready',
                @priority,
                0,
                5,
                now(),
                now()
            );
            """,
            connection,
            transaction);

        insertTask.Parameters.AddWithValue("business_event_id", businessEventId);
        insertTask.Parameters.AddWithValue("task_type", taskType);
        insertTask.Parameters.AddWithValue("payload", payloadJson);
        insertTask.Parameters.AddWithValue("priority", priority);

        await insertTask.ExecuteNonQueryAsync();

        await using var notifyCommand = new NpgsqlCommand("SELECT pg_notify('task_created', @payload);", connection, transaction);
        notifyCommand.Parameters.AddWithValue("payload", $"business_event_id={businessEventId};priority={priority}");
        await notifyCommand.ExecuteNonQueryAsync();

        await transaction.CommitAsync();

        return businessEventId;
    }

    private async Task<bool> TryProcessSingleTaskAsync(NpgsqlDataSource dataSource, string workerName, double failRate)
    {
        await using var connection = await dataSource.OpenConnectionAsync();
        await using var transaction = await connection.BeginTransactionAsync();

        QueueTask? task;

        await using (var takeCommand = new NpgsqlCommand(
                         """
                         SELECT id, priority, attempts, max_attempts, created_at
                         FROM queue.tasks
                         WHERE status = 'Ready'
                           AND scheduled_at <= now()
                         ORDER BY priority DESC, scheduled_at ASC, created_at ASC
                         LIMIT 1
                         FOR UPDATE SKIP LOCKED;
                         """,
                         connection,
                         transaction))
        await using (var reader = await takeCommand.ExecuteReaderAsync())
        {
            if (!await reader.ReadAsync())
            {
                await transaction.RollbackAsync();
                return false;
            }

            task = new QueueTask(
                reader.GetInt64(0),
                reader.GetInt32(1),
                reader.GetInt32(2),
                reader.GetInt32(3),
                reader.GetFieldValue<DateTimeOffset>(4));
        }

        await using (var updateRunningCommand = new NpgsqlCommand(
                         """
                         UPDATE queue.tasks
                         SET status = 'Running',
                             locked_by = @locked_by,
                             started_at = now()
                         WHERE id = @id;
                         """,
                         connection,
                         transaction))
        {
            updateRunningCommand.Parameters.AddWithValue("locked_by", workerName);
            updateRunningCommand.Parameters.AddWithValue("id", task.Id);
            await updateRunningCommand.ExecuteNonQueryAsync();
        }

        await transaction.CommitAsync();

        var processingDelayMs = task.Priority == 100
            ? Random.Shared.Next(100, 301)
            : Random.Shared.Next(200, 501);

        var stopwatch = Stopwatch.StartNew();
        await Task.Delay(processingDelayMs);
        stopwatch.Stop();

        var shouldFail = Random.Shared.NextDouble() < failRate;

        await using var finishConnection = await dataSource.OpenConnectionAsync();
        await using var finishTransaction = await finishConnection.BeginTransactionAsync();

        if (!shouldFail)
        {
            await using var completeCommand = new NpgsqlCommand(
                """
                UPDATE queue.tasks
                SET status = 'Completed',
                    completed_at = now()
                WHERE id = @id;
                """,
                finishConnection,
                finishTransaction);

            completeCommand.Parameters.AddWithValue("id", task.Id);
            await completeCommand.ExecuteNonQueryAsync();
            await finishTransaction.CommitAsync();

            Console.WriteLine(
                $"worker={workerName} task_id={task.Id} priority={task.Priority} result=Completed attempts={task.Attempts} processing_ms={stopwatch.ElapsedMilliseconds}");
            return true;
        }

        var nextAttempts = task.Attempts + 1;
        if (nextAttempts < task.MaxAttempts)
        {
            var backoffMinutes = 5 * (int)Math.Pow(2, task.Attempts);

            await using var retryCommand = new NpgsqlCommand(
                """
                UPDATE queue.tasks
                SET status = 'Ready',
                    attempts = @attempts,
                    scheduled_at = now() + (@backoff_minutes * interval '1 minute'),
                    last_error = @last_error
                WHERE id = @id;
                """,
                finishConnection,
                finishTransaction);

            retryCommand.Parameters.AddWithValue("attempts", nextAttempts);
            retryCommand.Parameters.AddWithValue("backoff_minutes", backoffMinutes);
            retryCommand.Parameters.AddWithValue("last_error", $"Simulated processing error at {DateTimeOffset.UtcNow:O}");
            retryCommand.Parameters.AddWithValue("id", task.Id);
            await retryCommand.ExecuteNonQueryAsync();
            await finishTransaction.CommitAsync();

            Console.WriteLine(
                $"worker={workerName} task_id={task.Id} priority={task.Priority} result=RetryScheduled attempts={nextAttempts} processing_ms={stopwatch.ElapsedMilliseconds}");
            return true;
        }

        await using var failCommand = new NpgsqlCommand(
            """
            UPDATE queue.tasks
            SET status = 'Failed',
                attempts = @attempts,
                completed_at = now(),
                last_error = @last_error
            WHERE id = @id;
            """,
            finishConnection,
            finishTransaction);

        failCommand.Parameters.AddWithValue("attempts", nextAttempts);
        failCommand.Parameters.AddWithValue("last_error", $"Simulated processing error at {DateTimeOffset.UtcNow:O}");
        failCommand.Parameters.AddWithValue("id", task.Id);
        await failCommand.ExecuteNonQueryAsync();
        await finishTransaction.CommitAsync();

        Console.WriteLine(
            $"worker={workerName} task_id={task.Id} priority={task.Priority} result=Failed attempts={nextAttempts} processing_ms={stopwatch.ElapsedMilliseconds}");
        return true;
    }

    private async Task<MonitorSnapshot> LoadMonitorSnapshotAsync(NpgsqlDataSource dataSource)
    {
        await using var connection = await dataSource.OpenConnectionAsync();

        await using var statsCommand = new NpgsqlCommand(
            """
            SELECT
                count(*) FILTER (WHERE status = 'Ready' AND scheduled_at <= now()) AS ready_count,
                count(*) FILTER (WHERE status = 'Running') AS running_count,
                count(*) FILTER (WHERE status = 'Completed') AS completed_count,
                count(*) FILTER (WHERE status = 'Failed') AS failed_count,
                min(created_at) FILTER (WHERE status = 'Ready' AND scheduled_at <= now()) AS oldest_ready_created_at,
                count(*) FILTER (
                    WHERE status IN ('Completed', 'Failed')
                      AND completed_at >= now() - interval '1 minute'
                ) AS completed_last_minute,
                count(*) FILTER (WHERE status = 'Completed' AND priority = 0) AS completed_priority_0,
                count(*) FILTER (WHERE status = 'Completed' AND priority = 100) AS completed_priority_100
            FROM queue.tasks;
            """,
            connection);

        await using var reader = await statsCommand.ExecuteReaderAsync();
        await reader.ReadAsync();

        var readyCount = reader.GetInt64(0);
        var runningCount = reader.GetInt64(1);
        var completedCount = reader.GetInt64(2);
        var failedCount = reader.GetInt64(3);

        TimeSpan? queueLag = null;
        if (!reader.IsDBNull(4))
        {
            var oldestReadyCreatedAt = reader.GetFieldValue<DateTimeOffset>(4);
            queueLag = DateTimeOffset.UtcNow - oldestReadyCreatedAt;
        }

        var completedLastMinute = reader.GetInt64(5);
        var completedPriority0 = reader.GetInt64(6);
        var completedPriority100 = reader.GetInt64(7);

        return new MonitorSnapshot(
            readyCount,
            runningCount,
            completedCount,
            failedCount,
            queueLag,
            Math.Round(completedLastMinute / 60.0, 2),
            completedPriority0,
            completedPriority100);
    }

    private int ParseIntOption(string optionName, int defaultValue)
    {
        var value = TryGetOptionValue(optionName);
        return value is not null && int.TryParse(value, out var parsed) ? parsed : defaultValue;
    }

    private double ParseDoubleOption(string optionName, double defaultValue)
    {
        var value = TryGetOptionValue(optionName);
        return value is not null && double.TryParse(value, out var parsed) ? parsed : defaultValue;
    }

    private string? TryGetOptionValue(string optionName)
    {
        for (var i = 0; i < _args.Length - 1; i++)
        {
            if (string.Equals(_args[i], optionName, StringComparison.OrdinalIgnoreCase))
            {
                return _args[i + 1];
            }
        }

        return null;
    }

    private string LoadConnectionString()
    {
        var fromEnvironment = Environment.GetEnvironmentVariable("QUEUE_CONNECTION_STRING");
        if (!string.IsNullOrWhiteSpace(fromEnvironment))
        {
            return fromEnvironment;
        }

        var appSettingsPath = Path.Combine(AppContext.BaseDirectory, "appsettings.json");
        if (!File.Exists(appSettingsPath))
        {
            throw new FileNotFoundException("appsettings.json was not found.", appSettingsPath);
        }

        using var stream = File.OpenRead(appSettingsPath);
        using var document = JsonDocument.Parse(stream);

        if (document.RootElement.TryGetProperty("ConnectionStrings", out var connectionStrings) &&
            connectionStrings.TryGetProperty("Postgres", out var postgresElement))
        {
            var connectionString = postgresElement.GetString();
            if (!string.IsNullOrWhiteSpace(connectionString))
            {
                return connectionString;
            }
        }

        throw new InvalidOperationException("ConnectionStrings:Postgres is missing in appsettings.json.");
    }

    private static void PrintUsage()
    {
        var builder = new StringBuilder();
        builder.AppendLine("Usage:");
        builder.AppendLine("  dotnet run -- producer --rate 100");
        builder.AppendLine("  dotnet run -- worker --name worker-1");
        builder.AppendLine("  dotnet run -- worker --name worker-2");
        builder.AppendLine("  dotnet run -- monitor");
        builder.AppendLine("  dotnet run -- cleanup");
        builder.AppendLine("  dotnet run -- stats");
        Console.WriteLine(builder.ToString());
    }

    private sealed record QueueTask(
        long Id,
        int Priority,
        int Attempts,
        int MaxAttempts,
        DateTimeOffset CreatedAt);

    private sealed record MonitorSnapshot(
        long ReadyCount,
        long RunningCount,
        long CompletedCount,
        long FailedCount,
        TimeSpan? QueueLag,
        double ThroughputPerSecond,
        long CompletedPriority0,
        long CompletedPriority100);
}
