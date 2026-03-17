--
-- PostgreSQL database dump
--

\restrict pjKfhlVhiz4jeeaZ62MImSomcjBcTnb3AMu3tGgaUukzMxbuPO6yhLA2pNFVUKT

-- Dumped from database version 16.11 (Debian 16.11-1.pgdg13+1)
-- Dumped by pg_dump version 16.11 (Debian 16.11-1.pgdg13+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: service; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA service;


ALTER SCHEMA service OWNER TO postgres;

--
-- Name: pageinspect; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pageinspect WITH SCHEMA public;


--
-- Name: EXTENSION pageinspect; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pageinspect IS 'inspect the contents of database pages at a low level';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: mvcc_test; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mvcc_test (
    id integer NOT NULL,
    value text
);


ALTER TABLE public.mvcc_test OWNER TO postgres;

--
-- Name: mvcc_test_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.mvcc_test_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.mvcc_test_id_seq OWNER TO postgres;

--
-- Name: mvcc_test_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.mvcc_test_id_seq OWNED BY public.mvcc_test.id;


--
-- Name: ad_photos; Type: TABLE; Schema: service; Owner: postgres
--

CREATE TABLE service.ad_photos (
    photo_id integer NOT NULL,
    ad_id integer NOT NULL,
    url text NOT NULL,
    is_primary boolean DEFAULT false
);


ALTER TABLE service.ad_photos OWNER TO postgres;

--
-- Name: ad_photos_photo_id_seq; Type: SEQUENCE; Schema: service; Owner: postgres
--

CREATE SEQUENCE service.ad_photos_photo_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE service.ad_photos_photo_id_seq OWNER TO postgres;

--
-- Name: ad_photos_photo_id_seq; Type: SEQUENCE OWNED BY; Schema: service; Owner: postgres
--

ALTER SEQUENCE service.ad_photos_photo_id_seq OWNED BY service.ad_photos.photo_id;


--
-- Name: ad_statuses; Type: TABLE; Schema: service; Owner: postgres
--

CREATE TABLE service.ad_statuses (
    id integer NOT NULL,
    code character varying(50) NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE service.ad_statuses OWNER TO postgres;

--
-- Name: ad_statuses_id_seq; Type: SEQUENCE; Schema: service; Owner: postgres
--

CREATE SEQUENCE service.ad_statuses_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE service.ad_statuses_id_seq OWNER TO postgres;

--
-- Name: ad_statuses_id_seq; Type: SEQUENCE OWNED BY; Schema: service; Owner: postgres
--

ALTER SEQUENCE service.ad_statuses_id_seq OWNED BY service.ad_statuses.id;


--
-- Name: ads; Type: TABLE; Schema: service; Owner: postgres
--

CREATE TABLE service.ads (
    ad_id integer NOT NULL,
    seller_id integer NOT NULL,
    vehicle_id integer NOT NULL,
    header_text character varying(200) NOT NULL,
    description text,
    price integer,
    publication_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    status_id integer NOT NULL,
    doc tsvector,
    meta jsonb DEFAULT '{}'::jsonb NOT NULL,
    active_period tsrange,
    tags text[] DEFAULT ARRAY[]::text[] NOT NULL,
    CONSTRAINT ads_price_check CHECK ((price >= 0))
);


ALTER TABLE service.ads OWNER TO postgres;

--
-- Name: ads_ad_id_seq; Type: SEQUENCE; Schema: service; Owner: postgres
--

CREATE SEQUENCE service.ads_ad_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE service.ads_ad_id_seq OWNER TO postgres;

--
-- Name: ads_ad_id_seq; Type: SEQUENCE OWNED BY; Schema: service; Owner: postgres
--

ALTER SEQUENCE service.ads_ad_id_seq OWNED BY service.ads.ad_id;


--
-- Name: body_types; Type: TABLE; Schema: service; Owner: postgres
--

CREATE TABLE service.body_types (
    id integer NOT NULL,
    code character varying(30) NOT NULL,
    name character varying(60) NOT NULL
);


ALTER TABLE service.body_types OWNER TO postgres;

--
-- Name: body_types_id_seq; Type: SEQUENCE; Schema: service; Owner: postgres
--

CREATE SEQUENCE service.body_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE service.body_types_id_seq OWNER TO postgres;

--
-- Name: body_types_id_seq; Type: SEQUENCE OWNED BY; Schema: service; Owner: postgres
--

ALTER SEQUENCE service.body_types_id_seq OWNED BY service.body_types.id;


--
-- Name: contracts; Type: TABLE; Schema: service; Owner: postgres
--

CREATE TABLE service.contracts (
    contract_id integer NOT NULL,
    ad_id integer,
    seller_id integer NOT NULL,
    buyer_user_id integer NOT NULL,
    amount integer NOT NULL,
    currency character(3) DEFAULT 'USD'::bpchar,
    contract_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    status character varying(20) NOT NULL,
    CONSTRAINT contracts_amount_check CHECK ((amount >= 0)),
    CONSTRAINT contracts_status_check CHECK (((status)::text = ANY ((ARRAY['active'::character varying, 'closed'::character varying, 'pending'::character varying])::text[])))
);


ALTER TABLE service.contracts OWNER TO postgres;

--
-- Name: contracts_contract_id_seq; Type: SEQUENCE; Schema: service; Owner: postgres
--

CREATE SEQUENCE service.contracts_contract_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE service.contracts_contract_id_seq OWNER TO postgres;

--
-- Name: contracts_contract_id_seq; Type: SEQUENCE OWNED BY; Schema: service; Owner: postgres
--

ALTER SEQUENCE service.contracts_contract_id_seq OWNED BY service.contracts.contract_id;


--
-- Name: favourites; Type: TABLE; Schema: service; Owner: postgres
--

CREATE TABLE service.favourites (
    user_id integer NOT NULL,
    ad_id integer NOT NULL,
    added_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE service.favourites OWNER TO postgres;

--
-- Name: feedbacks; Type: TABLE; Schema: service; Owner: postgres
--

CREATE TABLE service.feedbacks (
    feedback_id integer NOT NULL,
    user_id integer,
    seller_id integer NOT NULL,
    ad_id integer,
    text text,
    rating numeric(3,2),
    publication_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT feedbacks_rating_check CHECK (((rating >= (0)::numeric) AND (rating <= (5)::numeric)))
);


ALTER TABLE service.feedbacks OWNER TO postgres;

--
-- Name: feedbacks_feedback_id_seq; Type: SEQUENCE; Schema: service; Owner: postgres
--

CREATE SEQUENCE service.feedbacks_feedback_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE service.feedbacks_feedback_id_seq OWNER TO postgres;

--
-- Name: feedbacks_feedback_id_seq; Type: SEQUENCE OWNED BY; Schema: service; Owner: postgres
--

ALTER SEQUENCE service.feedbacks_feedback_id_seq OWNED BY service.feedbacks.feedback_id;


--
-- Name: flyway_schema_history; Type: TABLE; Schema: service; Owner: postgres
--

CREATE TABLE service.flyway_schema_history (
    installed_rank integer NOT NULL,
    version character varying(50),
    description character varying(200) NOT NULL,
    type character varying(20) NOT NULL,
    script character varying(1000) NOT NULL,
    checksum integer,
    installed_by character varying(100) NOT NULL,
    installed_on timestamp without time zone DEFAULT now() NOT NULL,
    execution_time integer NOT NULL,
    success boolean NOT NULL
);


ALTER TABLE service.flyway_schema_history OWNER TO postgres;

--
-- Name: fuel_types; Type: TABLE; Schema: service; Owner: postgres
--

CREATE TABLE service.fuel_types (
    id integer NOT NULL,
    code character varying(30) NOT NULL,
    name character varying(60) NOT NULL
);


ALTER TABLE service.fuel_types OWNER TO postgres;

--
-- Name: fuel_types_id_seq; Type: SEQUENCE; Schema: service; Owner: postgres
--

CREATE SEQUENCE service.fuel_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE service.fuel_types_id_seq OWNER TO postgres;

--
-- Name: fuel_types_id_seq; Type: SEQUENCE OWNED BY; Schema: service; Owner: postgres
--

ALTER SEQUENCE service.fuel_types_id_seq OWNED BY service.fuel_types.id;


--
-- Name: insurances; Type: TABLE; Schema: service; Owner: postgres
--

CREATE TABLE service.insurances (
    insurance_id integer NOT NULL,
    vehicle_id integer NOT NULL,
    insurer character varying(200),
    policy_number character varying(100),
    valid_from date,
    valid_to date,
    info text
);


ALTER TABLE service.insurances OWNER TO postgres;

--
-- Name: insurances_insurance_id_seq; Type: SEQUENCE; Schema: service; Owner: postgres
--

CREATE SEQUENCE service.insurances_insurance_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE service.insurances_insurance_id_seq OWNER TO postgres;

--
-- Name: insurances_insurance_id_seq; Type: SEQUENCE OWNED BY; Schema: service; Owner: postgres
--

ALTER SEQUENCE service.insurances_insurance_id_seq OWNED BY service.insurances.insurance_id;


--
-- Name: mileage_log; Type: TABLE; Schema: service; Owner: postgres
--

CREATE TABLE service.mileage_log (
    mileage_id integer NOT NULL,
    vehicle_id integer NOT NULL,
    recorded_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    mileage_km integer,
    CONSTRAINT mileage_log_mileage_km_check CHECK ((mileage_km >= 0))
);


ALTER TABLE service.mileage_log OWNER TO postgres;

--
-- Name: mileage_log_mileage_id_seq; Type: SEQUENCE; Schema: service; Owner: postgres
--

CREATE SEQUENCE service.mileage_log_mileage_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE service.mileage_log_mileage_id_seq OWNER TO postgres;

--
-- Name: mileage_log_mileage_id_seq; Type: SEQUENCE OWNED BY; Schema: service; Owner: postgres
--

ALTER SEQUENCE service.mileage_log_mileage_id_seq OWNED BY service.mileage_log.mileage_id;


--
-- Name: moderator_roles; Type: TABLE; Schema: service; Owner: postgres
--

CREATE TABLE service.moderator_roles (
    id integer NOT NULL,
    code character varying(30) NOT NULL,
    name character varying(60) NOT NULL
);


ALTER TABLE service.moderator_roles OWNER TO postgres;

--
-- Name: moderator_roles_id_seq; Type: SEQUENCE; Schema: service; Owner: postgres
--

CREATE SEQUENCE service.moderator_roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE service.moderator_roles_id_seq OWNER TO postgres;

--
-- Name: moderator_roles_id_seq; Type: SEQUENCE OWNED BY; Schema: service; Owner: postgres
--

ALTER SEQUENCE service.moderator_roles_id_seq OWNED BY service.moderator_roles.id;


--
-- Name: moderators; Type: TABLE; Schema: service; Owner: postgres
--

CREATE TABLE service.moderators (
    moderator_id integer NOT NULL,
    user_id integer NOT NULL,
    appointment_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    role_id integer
);


ALTER TABLE service.moderators OWNER TO postgres;

--
-- Name: moderators_moderator_id_seq; Type: SEQUENCE; Schema: service; Owner: postgres
--

CREATE SEQUENCE service.moderators_moderator_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE service.moderators_moderator_id_seq OWNER TO postgres;

--
-- Name: moderators_moderator_id_seq; Type: SEQUENCE OWNED BY; Schema: service; Owner: postgres
--

ALTER SEQUENCE service.moderators_moderator_id_seq OWNED BY service.moderators.moderator_id;


--
-- Name: ownerships; Type: TABLE; Schema: service; Owner: postgres
--

CREATE TABLE service.ownerships (
    ownership_id integer NOT NULL,
    vehicle_id integer NOT NULL,
    owner_user_id integer,
    purchase_date date,
    sale_date date,
    note text
);


ALTER TABLE service.ownerships OWNER TO postgres;

--
-- Name: ownerships_ownership_id_seq; Type: SEQUENCE; Schema: service; Owner: postgres
--

CREATE SEQUENCE service.ownerships_ownership_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE service.ownerships_ownership_id_seq OWNER TO postgres;

--
-- Name: ownerships_ownership_id_seq; Type: SEQUENCE OWNED BY; Schema: service; Owner: postgres
--

ALTER SEQUENCE service.ownerships_ownership_id_seq OWNED BY service.ownerships.ownership_id;


--
-- Name: sellers; Type: TABLE; Schema: service; Owner: postgres
--

CREATE TABLE service.sellers (
    seller_id integer NOT NULL,
    user_id integer NOT NULL,
    seller_type character varying(50) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT sellers_seller_type_check CHECK (((seller_type)::text = ANY ((ARRAY['individual'::character varying, 'company'::character varying])::text[])))
);


ALTER TABLE service.sellers OWNER TO postgres;

--
-- Name: seller_ratings; Type: VIEW; Schema: service; Owner: postgres
--

CREATE VIEW service.seller_ratings AS
 SELECT s.seller_id,
    avg(f.rating) AS avg_rating,
    count(f.feedback_id) AS reviews_count
   FROM (service.sellers s
     LEFT JOIN service.feedbacks f ON ((f.seller_id = s.seller_id)))
  GROUP BY s.seller_id;


ALTER VIEW service.seller_ratings OWNER TO postgres;

--
-- Name: sellers_seller_id_seq; Type: SEQUENCE; Schema: service; Owner: postgres
--

CREATE SEQUENCE service.sellers_seller_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE service.sellers_seller_id_seq OWNER TO postgres;

--
-- Name: sellers_seller_id_seq; Type: SEQUENCE OWNED BY; Schema: service; Owner: postgres
--

ALTER SEQUENCE service.sellers_seller_id_seq OWNED BY service.sellers.seller_id;


--
-- Name: transmissions; Type: TABLE; Schema: service; Owner: postgres
--

CREATE TABLE service.transmissions (
    id integer NOT NULL,
    code character varying(30) NOT NULL,
    name character varying(60) NOT NULL
);


ALTER TABLE service.transmissions OWNER TO postgres;

--
-- Name: transmissions_id_seq; Type: SEQUENCE; Schema: service; Owner: postgres
--

CREATE SEQUENCE service.transmissions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE service.transmissions_id_seq OWNER TO postgres;

--
-- Name: transmissions_id_seq; Type: SEQUENCE OWNED BY; Schema: service; Owner: postgres
--

ALTER SEQUENCE service.transmissions_id_seq OWNED BY service.transmissions.id;


--
-- Name: users; Type: TABLE; Schema: service; Owner: postgres
--

CREATE TABLE service.users (
    user_id integer NOT NULL,
    full_name character varying(100) NOT NULL,
    email character varying(254) NOT NULL,
    phone_number character varying(20),
    registration_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT users_phone_number_check CHECK (((phone_number)::text ~ '^\+[0-9]{10,15}$'::text))
);


ALTER TABLE service.users OWNER TO postgres;

--
-- Name: users_user_id_seq; Type: SEQUENCE; Schema: service; Owner: postgres
--

CREATE SEQUENCE service.users_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE service.users_user_id_seq OWNER TO postgres;

--
-- Name: users_user_id_seq; Type: SEQUENCE OWNED BY; Schema: service; Owner: postgres
--

ALTER SEQUENCE service.users_user_id_seq OWNED BY service.users.user_id;


--
-- Name: vehicle_flags; Type: TABLE; Schema: service; Owner: postgres
--

CREATE TABLE service.vehicle_flags (
    vehicle_id integer NOT NULL,
    is_classic boolean DEFAULT false,
    used_in_taxi boolean DEFAULT false
);


ALTER TABLE service.vehicle_flags OWNER TO postgres;

--
-- Name: vehicles; Type: TABLE; Schema: service; Owner: postgres
--

CREATE TABLE service.vehicles (
    vehicle_id integer NOT NULL,
    brand character varying(60) NOT NULL,
    model character varying(60) NOT NULL,
    year_of_manufacture integer,
    color character varying(30),
    body_type_id integer,
    transmission_id integer,
    fuel_type_id integer,
    power_hp integer,
    state_code character varying(20),
    vin character varying(17) NOT NULL,
    CONSTRAINT vehicles_power_hp_check CHECK ((power_hp > 0)),
    CONSTRAINT vehicles_state_code_check CHECK (((state_code)::text = ANY ((ARRAY['new'::character varying, 'used'::character varying, 'damaged'::character varying])::text[]))),
    CONSTRAINT vehicles_year_of_manufacture_check CHECK (((year_of_manufacture >= 1886) AND ((year_of_manufacture)::numeric <= EXTRACT(year FROM CURRENT_DATE))))
);


ALTER TABLE service.vehicles OWNER TO postgres;

--
-- Name: vehicles_vehicle_id_seq; Type: SEQUENCE; Schema: service; Owner: postgres
--

CREATE SEQUENCE service.vehicles_vehicle_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE service.vehicles_vehicle_id_seq OWNER TO postgres;

--
-- Name: vehicles_vehicle_id_seq; Type: SEQUENCE OWNED BY; Schema: service; Owner: postgres
--

ALTER SEQUENCE service.vehicles_vehicle_id_seq OWNED BY service.vehicles.vehicle_id;


--
-- Name: mvcc_test id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mvcc_test ALTER COLUMN id SET DEFAULT nextval('public.mvcc_test_id_seq'::regclass);


--
-- Name: ad_photos photo_id; Type: DEFAULT; Schema: service; Owner: postgres
--

ALTER TABLE ONLY service.ad_photos ALTER COLUMN photo_id SET DEFAULT nextval('service.ad_photos_photo_id_seq'::regclass);


--
-- Name: ad_statuses id; Type: DEFAULT; Schema: service; Owner: postgres
--

ALTER TABLE ONLY service.ad_statuses ALTER COLUMN id SET DEFAULT nextval('service.ad_statuses_id_seq'::regclass);


--
-- Name: ads ad_id; Type: DEFAULT; Schema: service; Owner: postgres
--

ALTER TABLE ONLY service.ads ALTER COLUMN ad_id SET DEFAULT nextval('service.ads_ad_id_seq'::regclass);


--
-- Name: body_types id; Type: DEFAULT; Schema: service; Owner: postgres
--

ALTER TABLE ONLY service.body_types ALTER COLUMN id SET DEFAULT nextval('service.body_types_id_seq'::regclass);


--
-- Name: contracts contract_id; Type: DEFAULT; Schema: service; Owner: postgres
--

ALTER TABLE ONLY service.contracts ALTER COLUMN contract_id SET DEFAULT nextval('service.contracts_contract_id_seq'::regclass);


--
-- Name: feedbacks feedback_id; Type: DEFAULT; Schema: service; Owner: postgres
--

ALTER TABLE ONLY service.feedbacks ALTER COLUMN feedback_id SET DEFAULT nextval('service.feedbacks_feedback_id_seq'::regclass);


--
-- Name: fuel_types id; Type: DEFAULT; Schema: service; Owner: postgres
--

ALTER TABLE ONLY service.fuel_types ALTER COLUMN id SET DEFAULT nextval('service.fuel_types_id_seq'::regclass);


--
-- Name: insurances insurance_id; Type: DEFAULT; Schema: service; Owner: postgres
--

ALTER TABLE ONLY service.insurances ALTER COLUMN insurance_id SET DEFAULT nextval('service.insurances_insurance_id_seq'::regclass);


--
-- Name: mileage_log mileage_id; Type: DEFAULT; Schema: service; Owner: postgres
--

ALTER TABLE ONLY service.mileage_log ALTER COLUMN mileage_id SET DEFAULT nextval('service.mileage_log_mileage_id_seq'::regclass);


--
-- Name: moderator_roles id; Type: DEFAULT; Schema: service; Owner: postgres
--

ALTER TABLE ONLY service.moderator_roles ALTER COLUMN id SET DEFAULT nextval('service.moderator_roles_id_seq'::regclass);


--
-- Name: moderators moderator_id; Type: DEFAULT; Schema: service; Owner: postgres
--

ALTER TABLE ONLY service.moderators ALTER COLUMN moderator_id SET DEFAULT nextval('service.moderators_moderator_id_seq'::regclass);


--
-- Name: ownerships ownership_id; Type: DEFAULT; Schema: service; Owner: postgres
--

ALTER TABLE ONLY service.ownerships ALTER COLUMN ownership_id SET DEFAULT nextval('service.ownerships_ownership_id_seq'::regclass);


--
-- Name: sellers seller_id; Type: DEFAULT; Schema: service; Owner: postgres
--

ALTER TABLE ONLY service.sellers ALTER COLUMN seller_id SET DEFAULT nextval('service.sellers_seller_id_seq'::regclass);


--
-- Name: transmissions id; Type: DEFAULT; Schema: service; Owner: postgres
--

ALTER TABLE ONLY service.transmissions ALTER COLUMN id SET DEFAULT nextval('service.transmissions_id_seq'::regclass);


--
-- Name: users user_id; Type: DEFAULT; Schema: service; Owner: postgres
--

ALTER TABLE ONLY service.users ALTER COLUMN user_id SET DEFAULT nextval('service.users_user_id_seq'::regclass);


--
-- Name: vehicles vehicle_id; Type: DEFAULT; Schema: service; Owner: postgres
--

ALTER TABLE ONLY service.vehicles ALTER COLUMN vehicle_id SET DEFAULT nextval('service.vehicles_vehicle_id_seq'::regclass);


--
-- Name: mvcc_test mvcc_test_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mvcc_test
    ADD CONSTRAINT mvcc_test_pkey PRIMARY KEY (id);


--
-- Name: ad_photos ad_photos_pkey; Type: CONSTRAINT; Schema: service; Owner: postgres
--

ALTER TABLE ONLY service.ad_photos
    ADD CONSTRAINT ad_photos_pkey PRIMARY KEY (photo_id);


--
-- Name: ad_statuses ad_statuses_code_key; Type: CONSTRAINT; Schema: service; Owner: postgres
--

ALTER TABLE ONLY service.ad_statuses
    ADD CONSTRAINT ad_statuses_code_key UNIQUE (code);


--
-- Name: ad_statuses ad_statuses_pkey; Type: CONSTRAINT; Schema: service; Owner: postgres
--

ALTER TABLE ONLY service.ad_statuses
    ADD CONSTRAINT ad_statuses_pkey PRIMARY KEY (id);


--
-- Name: ads ads_pkey; Type: CONSTRAINT; Schema: service; Owner: postgres
--

ALTER TABLE ONLY service.ads
    ADD CONSTRAINT ads_pkey PRIMARY KEY (ad_id);


--
-- Name: body_types body_types_code_key; Type: CONSTRAINT; Schema: service; Owner: postgres
--

ALTER TABLE ONLY service.body_types
    ADD CONSTRAINT body_types_code_key UNIQUE (code);


--
-- Name: body_types body_types_pkey; Type: CONSTRAINT; Schema: service; Owner: postgres
--

ALTER TABLE ONLY service.body_types
    ADD CONSTRAINT body_types_pkey PRIMARY KEY (id);


--
-- Name: contracts contracts_pkey; Type: CONSTRAINT; Schema: service; Owner: postgres
--

ALTER TABLE ONLY service.contracts
    ADD CONSTRAINT contracts_pkey PRIMARY KEY (contract_id);


--
-- Name: favourites favourites_pkey; Type: CONSTRAINT; Schema: service; Owner: postgres
--

ALTER TABLE ONLY service.favourites
    ADD CONSTRAINT favourites_pkey PRIMARY KEY (user_id, ad_id);


--
-- Name: feedbacks feedbacks_pkey; Type: CONSTRAINT; Schema: service; Owner: postgres
--

ALTER TABLE ONLY service.feedbacks
    ADD CONSTRAINT feedbacks_pkey PRIMARY KEY (feedback_id);


--
-- Name: feedbacks feedbacks_user_id_seller_id_ad_id_key; Type: CONSTRAINT; Schema: service; Owner: postgres
--

ALTER TABLE ONLY service.feedbacks
    ADD CONSTRAINT feedbacks_user_id_seller_id_ad_id_key UNIQUE (user_id, seller_id, ad_id);


--
-- Name: flyway_schema_history flyway_schema_history_pk; Type: CONSTRAINT; Schema: service; Owner: postgres
--

ALTER TABLE ONLY service.flyway_schema_history
    ADD CONSTRAINT flyway_schema_history_pk PRIMARY KEY (installed_rank);


--
-- Name: fuel_types fuel_types_code_key; Type: CONSTRAINT; Schema: service; Owner: postgres
--

ALTER TABLE ONLY service.fuel_types
    ADD CONSTRAINT fuel_types_code_key UNIQUE (code);


--
-- Name: fuel_types fuel_types_pkey; Type: CONSTRAINT; Schema: service; Owner: postgres
--

ALTER TABLE ONLY service.fuel_types
    ADD CONSTRAINT fuel_types_pkey PRIMARY KEY (id);


--
-- Name: insurances insurances_pkey; Type: CONSTRAINT; Schema: service; Owner: postgres
--

ALTER TABLE ONLY service.insurances
    ADD CONSTRAINT insurances_pkey PRIMARY KEY (insurance_id);


--
-- Name: mileage_log mileage_log_pkey; Type: CONSTRAINT; Schema: service; Owner: postgres
--

ALTER TABLE ONLY service.mileage_log
    ADD CONSTRAINT mileage_log_pkey PRIMARY KEY (mileage_id);


--
-- Name: moderator_roles moderator_roles_code_key; Type: CONSTRAINT; Schema: service; Owner: postgres
--

ALTER TABLE ONLY service.moderator_roles
    ADD CONSTRAINT moderator_roles_code_key UNIQUE (code);


--
-- Name: moderator_roles moderator_roles_pkey; Type: CONSTRAINT; Schema: service; Owner: postgres
--

ALTER TABLE ONLY service.moderator_roles
    ADD CONSTRAINT moderator_roles_pkey PRIMARY KEY (id);


--
-- Name: moderators moderators_pkey; Type: CONSTRAINT; Schema: service; Owner: postgres
--

ALTER TABLE ONLY service.moderators
    ADD CONSTRAINT moderators_pkey PRIMARY KEY (moderator_id);


--
-- Name: ownerships ownerships_pkey; Type: CONSTRAINT; Schema: service; Owner: postgres
--

ALTER TABLE ONLY service.ownerships
    ADD CONSTRAINT ownerships_pkey PRIMARY KEY (ownership_id);


--
-- Name: sellers sellers_pkey; Type: CONSTRAINT; Schema: service; Owner: postgres
--

ALTER TABLE ONLY service.sellers
    ADD CONSTRAINT sellers_pkey PRIMARY KEY (seller_id);


--
-- Name: transmissions transmissions_code_key; Type: CONSTRAINT; Schema: service; Owner: postgres
--

ALTER TABLE ONLY service.transmissions
    ADD CONSTRAINT transmissions_code_key UNIQUE (code);


--
-- Name: transmissions transmissions_pkey; Type: CONSTRAINT; Schema: service; Owner: postgres
--

ALTER TABLE ONLY service.transmissions
    ADD CONSTRAINT transmissions_pkey PRIMARY KEY (id);


--
-- Name: users users_email_key; Type: CONSTRAINT; Schema: service; Owner: postgres
--

ALTER TABLE ONLY service.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: service; Owner: postgres
--

ALTER TABLE ONLY service.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- Name: vehicle_flags vehicle_flags_pkey; Type: CONSTRAINT; Schema: service; Owner: postgres
--

ALTER TABLE ONLY service.vehicle_flags
    ADD CONSTRAINT vehicle_flags_pkey PRIMARY KEY (vehicle_id);


--
-- Name: vehicles vehicles_pkey; Type: CONSTRAINT; Schema: service; Owner: postgres
--

ALTER TABLE ONLY service.vehicles
    ADD CONSTRAINT vehicles_pkey PRIMARY KEY (vehicle_id);


--
-- Name: vehicles vehicles_vin_key; Type: CONSTRAINT; Schema: service; Owner: postgres
--

ALTER TABLE ONLY service.vehicles
    ADD CONSTRAINT vehicles_vin_key UNIQUE (vin);


--
-- Name: flyway_schema_history_s_idx; Type: INDEX; Schema: service; Owner: postgres
--

CREATE INDEX flyway_schema_history_s_idx ON service.flyway_schema_history USING btree (success);


--
-- Name: gin_ads_doc_idx; Type: INDEX; Schema: service; Owner: postgres
--

CREATE INDEX gin_ads_doc_idx ON service.ads USING gin (doc);


--
-- Name: gist_ads_period_idx; Type: INDEX; Schema: service; Owner: postgres
--

CREATE INDEX gist_ads_period_idx ON service.ads USING gist (active_period);


--
-- Name: idx_ads_active_period_gist; Type: INDEX; Schema: service; Owner: postgres
--

CREATE INDEX idx_ads_active_period_gist ON service.ads USING gist (active_period);


--
-- Name: idx_ads_doc_gin; Type: INDEX; Schema: service; Owner: postgres
--

CREATE INDEX idx_ads_doc_gin ON service.ads USING gin (doc);


--
-- Name: idx_ads_meta_gin; Type: INDEX; Schema: service; Owner: postgres
--

CREATE INDEX idx_ads_meta_gin ON service.ads USING gin (meta);


--
-- Name: idx_ads_price; Type: INDEX; Schema: service; Owner: postgres
--

CREATE INDEX idx_ads_price ON service.ads USING btree (price);


--
-- Name: idx_ads_pubdate; Type: INDEX; Schema: service; Owner: postgres
--

CREATE INDEX idx_ads_pubdate ON service.ads USING btree (publication_date);


--
-- Name: idx_ads_seller; Type: INDEX; Schema: service; Owner: postgres
--

CREATE INDEX idx_ads_seller ON service.ads USING btree (seller_id);


--
-- Name: idx_ads_status; Type: INDEX; Schema: service; Owner: postgres
--

CREATE INDEX idx_ads_status ON service.ads USING btree (status_id);


--
-- Name: idx_ads_vehicle; Type: INDEX; Schema: service; Owner: postgres
--

CREATE INDEX idx_ads_vehicle ON service.ads USING btree (vehicle_id);


--
-- Name: idx_fav_ad; Type: INDEX; Schema: service; Owner: postgres
--

CREATE INDEX idx_fav_ad ON service.favourites USING btree (ad_id);


--
-- Name: idx_fav_user; Type: INDEX; Schema: service; Owner: postgres
--

CREATE INDEX idx_fav_user ON service.favourites USING btree (user_id);


--
-- Name: idx_feedback_seller; Type: INDEX; Schema: service; Owner: postgres
--

CREATE INDEX idx_feedback_seller ON service.feedbacks USING btree (seller_id);


--
-- Name: idx_feedback_user; Type: INDEX; Schema: service; Owner: postgres
--

CREATE INDEX idx_feedback_user ON service.feedbacks USING btree (user_id);


--
-- Name: idx_sellers_user; Type: INDEX; Schema: service; Owner: postgres
--

CREATE INDEX idx_sellers_user ON service.sellers USING btree (user_id);


--
-- Name: ad_photos ad_photos_ad_id_fkey; Type: FK CONSTRAINT; Schema: service; Owner: postgres
--

ALTER TABLE ONLY service.ad_photos
    ADD CONSTRAINT ad_photos_ad_id_fkey FOREIGN KEY (ad_id) REFERENCES service.ads(ad_id) ON DELETE CASCADE;


--
-- Name: ads ads_seller_id_fkey; Type: FK CONSTRAINT; Schema: service; Owner: postgres
--

ALTER TABLE ONLY service.ads
    ADD CONSTRAINT ads_seller_id_fkey FOREIGN KEY (seller_id) REFERENCES service.sellers(seller_id) ON DELETE CASCADE;


--
-- Name: ads ads_status_id_fkey; Type: FK CONSTRAINT; Schema: service; Owner: postgres
--

ALTER TABLE ONLY service.ads
    ADD CONSTRAINT ads_status_id_fkey FOREIGN KEY (status_id) REFERENCES service.ad_statuses(id);


--
-- Name: ads ads_vehicle_id_fkey; Type: FK CONSTRAINT; Schema: service; Owner: postgres
--

ALTER TABLE ONLY service.ads
    ADD CONSTRAINT ads_vehicle_id_fkey FOREIGN KEY (vehicle_id) REFERENCES service.vehicles(vehicle_id) ON DELETE CASCADE;


--
-- Name: contracts contracts_ad_id_fkey; Type: FK CONSTRAINT; Schema: service; Owner: postgres
--

ALTER TABLE ONLY service.contracts
    ADD CONSTRAINT contracts_ad_id_fkey FOREIGN KEY (ad_id) REFERENCES service.ads(ad_id);


--
-- Name: contracts contracts_buyer_user_id_fkey; Type: FK CONSTRAINT; Schema: service; Owner: postgres
--

ALTER TABLE ONLY service.contracts
    ADD CONSTRAINT contracts_buyer_user_id_fkey FOREIGN KEY (buyer_user_id) REFERENCES service.users(user_id);


--
-- Name: contracts contracts_seller_id_fkey; Type: FK CONSTRAINT; Schema: service; Owner: postgres
--

ALTER TABLE ONLY service.contracts
    ADD CONSTRAINT contracts_seller_id_fkey FOREIGN KEY (seller_id) REFERENCES service.sellers(seller_id);


--
-- Name: favourites favourites_ad_id_fkey; Type: FK CONSTRAINT; Schema: service; Owner: postgres
--

ALTER TABLE ONLY service.favourites
    ADD CONSTRAINT favourites_ad_id_fkey FOREIGN KEY (ad_id) REFERENCES service.ads(ad_id) ON DELETE CASCADE;


--
-- Name: favourites favourites_user_id_fkey; Type: FK CONSTRAINT; Schema: service; Owner: postgres
--

ALTER TABLE ONLY service.favourites
    ADD CONSTRAINT favourites_user_id_fkey FOREIGN KEY (user_id) REFERENCES service.users(user_id) ON DELETE CASCADE;


--
-- Name: feedbacks feedbacks_ad_id_fkey; Type: FK CONSTRAINT; Schema: service; Owner: postgres
--

ALTER TABLE ONLY service.feedbacks
    ADD CONSTRAINT feedbacks_ad_id_fkey FOREIGN KEY (ad_id) REFERENCES service.ads(ad_id) ON DELETE SET NULL;


--
-- Name: feedbacks feedbacks_seller_id_fkey; Type: FK CONSTRAINT; Schema: service; Owner: postgres
--

ALTER TABLE ONLY service.feedbacks
    ADD CONSTRAINT feedbacks_seller_id_fkey FOREIGN KEY (seller_id) REFERENCES service.sellers(seller_id) ON DELETE CASCADE;


--
-- Name: feedbacks feedbacks_user_id_fkey; Type: FK CONSTRAINT; Schema: service; Owner: postgres
--

ALTER TABLE ONLY service.feedbacks
    ADD CONSTRAINT feedbacks_user_id_fkey FOREIGN KEY (user_id) REFERENCES service.users(user_id) ON DELETE SET NULL;


--
-- Name: insurances insurances_vehicle_id_fkey; Type: FK CONSTRAINT; Schema: service; Owner: postgres
--

ALTER TABLE ONLY service.insurances
    ADD CONSTRAINT insurances_vehicle_id_fkey FOREIGN KEY (vehicle_id) REFERENCES service.vehicles(vehicle_id) ON DELETE CASCADE;


--
-- Name: mileage_log mileage_log_vehicle_id_fkey; Type: FK CONSTRAINT; Schema: service; Owner: postgres
--

ALTER TABLE ONLY service.mileage_log
    ADD CONSTRAINT mileage_log_vehicle_id_fkey FOREIGN KEY (vehicle_id) REFERENCES service.vehicles(vehicle_id) ON DELETE CASCADE;


--
-- Name: moderators moderators_role_id_fkey; Type: FK CONSTRAINT; Schema: service; Owner: postgres
--

ALTER TABLE ONLY service.moderators
    ADD CONSTRAINT moderators_role_id_fkey FOREIGN KEY (role_id) REFERENCES service.moderator_roles(id);


--
-- Name: moderators moderators_user_id_fkey; Type: FK CONSTRAINT; Schema: service; Owner: postgres
--

ALTER TABLE ONLY service.moderators
    ADD CONSTRAINT moderators_user_id_fkey FOREIGN KEY (user_id) REFERENCES service.users(user_id) ON DELETE CASCADE;


--
-- Name: ownerships ownerships_owner_user_id_fkey; Type: FK CONSTRAINT; Schema: service; Owner: postgres
--

ALTER TABLE ONLY service.ownerships
    ADD CONSTRAINT ownerships_owner_user_id_fkey FOREIGN KEY (owner_user_id) REFERENCES service.users(user_id) ON DELETE SET NULL;


--
-- Name: ownerships ownerships_vehicle_id_fkey; Type: FK CONSTRAINT; Schema: service; Owner: postgres
--

ALTER TABLE ONLY service.ownerships
    ADD CONSTRAINT ownerships_vehicle_id_fkey FOREIGN KEY (vehicle_id) REFERENCES service.vehicles(vehicle_id) ON DELETE CASCADE;


--
-- Name: sellers sellers_user_id_fkey; Type: FK CONSTRAINT; Schema: service; Owner: postgres
--

ALTER TABLE ONLY service.sellers
    ADD CONSTRAINT sellers_user_id_fkey FOREIGN KEY (user_id) REFERENCES service.users(user_id) ON DELETE CASCADE;


--
-- Name: vehicle_flags vehicle_flags_vehicle_id_fkey; Type: FK CONSTRAINT; Schema: service; Owner: postgres
--

ALTER TABLE ONLY service.vehicle_flags
    ADD CONSTRAINT vehicle_flags_vehicle_id_fkey FOREIGN KEY (vehicle_id) REFERENCES service.vehicles(vehicle_id) ON DELETE CASCADE;


--
-- Name: vehicles vehicles_body_type_id_fkey; Type: FK CONSTRAINT; Schema: service; Owner: postgres
--

ALTER TABLE ONLY service.vehicles
    ADD CONSTRAINT vehicles_body_type_id_fkey FOREIGN KEY (body_type_id) REFERENCES service.body_types(id);


--
-- Name: vehicles vehicles_fuel_type_id_fkey; Type: FK CONSTRAINT; Schema: service; Owner: postgres
--

ALTER TABLE ONLY service.vehicles
    ADD CONSTRAINT vehicles_fuel_type_id_fkey FOREIGN KEY (fuel_type_id) REFERENCES service.fuel_types(id);


--
-- Name: vehicles vehicles_transmission_id_fkey; Type: FK CONSTRAINT; Schema: service; Owner: postgres
--

ALTER TABLE ONLY service.vehicles
    ADD CONSTRAINT vehicles_transmission_id_fkey FOREIGN KEY (transmission_id) REFERENCES service.transmissions(id);


--
-- Name: SCHEMA service; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA service TO app;
GRANT USAGE ON SCHEMA service TO readonly;


--
-- Name: TABLE ad_photos; Type: ACL; Schema: service; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE service.ad_photos TO app;
GRANT SELECT ON TABLE service.ad_photos TO readonly;


--
-- Name: SEQUENCE ad_photos_photo_id_seq; Type: ACL; Schema: service; Owner: postgres
--

GRANT ALL ON SEQUENCE service.ad_photos_photo_id_seq TO app;
GRANT SELECT,USAGE ON SEQUENCE service.ad_photos_photo_id_seq TO readonly;


--
-- Name: TABLE ad_statuses; Type: ACL; Schema: service; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE service.ad_statuses TO app;
GRANT SELECT ON TABLE service.ad_statuses TO readonly;


--
-- Name: SEQUENCE ad_statuses_id_seq; Type: ACL; Schema: service; Owner: postgres
--

GRANT ALL ON SEQUENCE service.ad_statuses_id_seq TO app;
GRANT SELECT,USAGE ON SEQUENCE service.ad_statuses_id_seq TO readonly;


--
-- Name: TABLE ads; Type: ACL; Schema: service; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE service.ads TO app;
GRANT SELECT ON TABLE service.ads TO readonly;


--
-- Name: SEQUENCE ads_ad_id_seq; Type: ACL; Schema: service; Owner: postgres
--

GRANT ALL ON SEQUENCE service.ads_ad_id_seq TO app;
GRANT SELECT,USAGE ON SEQUENCE service.ads_ad_id_seq TO readonly;


--
-- Name: TABLE body_types; Type: ACL; Schema: service; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE service.body_types TO app;
GRANT SELECT ON TABLE service.body_types TO readonly;


--
-- Name: SEQUENCE body_types_id_seq; Type: ACL; Schema: service; Owner: postgres
--

GRANT ALL ON SEQUENCE service.body_types_id_seq TO app;
GRANT SELECT,USAGE ON SEQUENCE service.body_types_id_seq TO readonly;


--
-- Name: TABLE contracts; Type: ACL; Schema: service; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE service.contracts TO app;
GRANT SELECT ON TABLE service.contracts TO readonly;


--
-- Name: SEQUENCE contracts_contract_id_seq; Type: ACL; Schema: service; Owner: postgres
--

GRANT ALL ON SEQUENCE service.contracts_contract_id_seq TO app;
GRANT SELECT,USAGE ON SEQUENCE service.contracts_contract_id_seq TO readonly;


--
-- Name: TABLE favourites; Type: ACL; Schema: service; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE service.favourites TO app;
GRANT SELECT ON TABLE service.favourites TO readonly;


--
-- Name: TABLE feedbacks; Type: ACL; Schema: service; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE service.feedbacks TO app;
GRANT SELECT ON TABLE service.feedbacks TO readonly;


--
-- Name: SEQUENCE feedbacks_feedback_id_seq; Type: ACL; Schema: service; Owner: postgres
--

GRANT ALL ON SEQUENCE service.feedbacks_feedback_id_seq TO app;
GRANT SELECT,USAGE ON SEQUENCE service.feedbacks_feedback_id_seq TO readonly;


--
-- Name: TABLE flyway_schema_history; Type: ACL; Schema: service; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE service.flyway_schema_history TO app;
GRANT SELECT ON TABLE service.flyway_schema_history TO readonly;


--
-- Name: TABLE fuel_types; Type: ACL; Schema: service; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE service.fuel_types TO app;
GRANT SELECT ON TABLE service.fuel_types TO readonly;


--
-- Name: SEQUENCE fuel_types_id_seq; Type: ACL; Schema: service; Owner: postgres
--

GRANT ALL ON SEQUENCE service.fuel_types_id_seq TO app;
GRANT SELECT,USAGE ON SEQUENCE service.fuel_types_id_seq TO readonly;


--
-- Name: TABLE insurances; Type: ACL; Schema: service; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE service.insurances TO app;
GRANT SELECT ON TABLE service.insurances TO readonly;


--
-- Name: SEQUENCE insurances_insurance_id_seq; Type: ACL; Schema: service; Owner: postgres
--

GRANT ALL ON SEQUENCE service.insurances_insurance_id_seq TO app;
GRANT SELECT,USAGE ON SEQUENCE service.insurances_insurance_id_seq TO readonly;


--
-- Name: TABLE mileage_log; Type: ACL; Schema: service; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE service.mileage_log TO app;
GRANT SELECT ON TABLE service.mileage_log TO readonly;


--
-- Name: SEQUENCE mileage_log_mileage_id_seq; Type: ACL; Schema: service; Owner: postgres
--

GRANT ALL ON SEQUENCE service.mileage_log_mileage_id_seq TO app;
GRANT SELECT,USAGE ON SEQUENCE service.mileage_log_mileage_id_seq TO readonly;


--
-- Name: TABLE moderator_roles; Type: ACL; Schema: service; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE service.moderator_roles TO app;
GRANT SELECT ON TABLE service.moderator_roles TO readonly;


--
-- Name: SEQUENCE moderator_roles_id_seq; Type: ACL; Schema: service; Owner: postgres
--

GRANT ALL ON SEQUENCE service.moderator_roles_id_seq TO app;
GRANT SELECT,USAGE ON SEQUENCE service.moderator_roles_id_seq TO readonly;


--
-- Name: TABLE moderators; Type: ACL; Schema: service; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE service.moderators TO app;
GRANT SELECT ON TABLE service.moderators TO readonly;


--
-- Name: SEQUENCE moderators_moderator_id_seq; Type: ACL; Schema: service; Owner: postgres
--

GRANT ALL ON SEQUENCE service.moderators_moderator_id_seq TO app;
GRANT SELECT,USAGE ON SEQUENCE service.moderators_moderator_id_seq TO readonly;


--
-- Name: TABLE ownerships; Type: ACL; Schema: service; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE service.ownerships TO app;
GRANT SELECT ON TABLE service.ownerships TO readonly;


--
-- Name: SEQUENCE ownerships_ownership_id_seq; Type: ACL; Schema: service; Owner: postgres
--

GRANT ALL ON SEQUENCE service.ownerships_ownership_id_seq TO app;
GRANT SELECT,USAGE ON SEQUENCE service.ownerships_ownership_id_seq TO readonly;


--
-- Name: TABLE sellers; Type: ACL; Schema: service; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE service.sellers TO app;
GRANT SELECT ON TABLE service.sellers TO readonly;


--
-- Name: TABLE seller_ratings; Type: ACL; Schema: service; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE service.seller_ratings TO app;
GRANT SELECT ON TABLE service.seller_ratings TO readonly;


--
-- Name: SEQUENCE sellers_seller_id_seq; Type: ACL; Schema: service; Owner: postgres
--

GRANT ALL ON SEQUENCE service.sellers_seller_id_seq TO app;
GRANT SELECT,USAGE ON SEQUENCE service.sellers_seller_id_seq TO readonly;


--
-- Name: TABLE transmissions; Type: ACL; Schema: service; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE service.transmissions TO app;
GRANT SELECT ON TABLE service.transmissions TO readonly;


--
-- Name: SEQUENCE transmissions_id_seq; Type: ACL; Schema: service; Owner: postgres
--

GRANT ALL ON SEQUENCE service.transmissions_id_seq TO app;
GRANT SELECT,USAGE ON SEQUENCE service.transmissions_id_seq TO readonly;


--
-- Name: TABLE users; Type: ACL; Schema: service; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE service.users TO app;
GRANT SELECT ON TABLE service.users TO readonly;


--
-- Name: SEQUENCE users_user_id_seq; Type: ACL; Schema: service; Owner: postgres
--

GRANT ALL ON SEQUENCE service.users_user_id_seq TO app;
GRANT SELECT,USAGE ON SEQUENCE service.users_user_id_seq TO readonly;


--
-- Name: TABLE vehicle_flags; Type: ACL; Schema: service; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE service.vehicle_flags TO app;
GRANT SELECT ON TABLE service.vehicle_flags TO readonly;


--
-- Name: TABLE vehicles; Type: ACL; Schema: service; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE service.vehicles TO app;
GRANT SELECT ON TABLE service.vehicles TO readonly;


--
-- Name: SEQUENCE vehicles_vehicle_id_seq; Type: ACL; Schema: service; Owner: postgres
--

GRANT ALL ON SEQUENCE service.vehicles_vehicle_id_seq TO app;
GRANT SELECT,USAGE ON SEQUENCE service.vehicles_vehicle_id_seq TO readonly;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: service; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA service GRANT ALL ON SEQUENCES TO app;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA service GRANT SELECT,USAGE ON SEQUENCES TO readonly;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: service; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA service GRANT SELECT,INSERT,DELETE,UPDATE ON TABLES TO app;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA service GRANT SELECT ON TABLES TO readonly;


--
-- PostgreSQL database dump complete
--

\unrestrict pjKfhlVhiz4jeeaZ62MImSomcjBcTnb3AMu3tGgaUukzMxbuPO6yhLA2pNFVUKT

