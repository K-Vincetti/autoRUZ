CREATE SCHEMA IF NOT EXISTS queue;

CREATE TABLE IF NOT EXISTS queue.business_events (
    id BIGSERIAL PRIMARY KEY,
    event_type TEXT NOT NULL,
    advertisement_id BIGINT NOT NULL,
    payload JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS queue.tasks (
    id BIGSERIAL PRIMARY KEY,
    business_event_id BIGINT NOT NULL REFERENCES queue.business_events(id),
    task_type TEXT NOT NULL,
    payload JSONB NOT NULL DEFAULT '{}'::jsonb,
    status TEXT NOT NULL,
    priority INT NOT NULL DEFAULT 0,
    attempts INT NOT NULL DEFAULT 0,
    max_attempts INT NOT NULL DEFAULT 5,
    scheduled_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    started_at TIMESTAMPTZ NULL,
    completed_at TIMESTAMPTZ NULL,
    locked_by TEXT NULL,
    last_error TEXT NULL,
    CONSTRAINT ck_tasks_status
        CHECK (status IN ('Ready', 'Running', 'Completed', 'Failed')),
    CONSTRAINT ck_tasks_attempts
        CHECK (attempts >= 0),
    CONSTRAINT ck_tasks_max_attempts
        CHECK (max_attempts > 0)
);

CREATE INDEX IF NOT EXISTS ix_tasks_ready_pick
    ON queue.tasks (status, scheduled_at, priority DESC, created_at)
    WHERE status = 'Ready';

CREATE INDEX IF NOT EXISTS ix_tasks_status
    ON queue.tasks (status);

CREATE INDEX IF NOT EXISTS ix_tasks_created_at
    ON queue.tasks (created_at);

CREATE INDEX IF NOT EXISTS ix_tasks_completed_at
    ON queue.tasks (completed_at);

ALTER TABLE queue.tasks SET (
    autovacuum_vacuum_scale_factor = 0.01,
    autovacuum_vacuum_threshold = 50,
    autovacuum_analyze_scale_factor = 0.01,
    autovacuum_analyze_threshold = 50
);
