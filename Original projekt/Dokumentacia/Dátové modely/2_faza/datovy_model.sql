--
-- PostgreSQL database dump
--

\restrict SBMMITBWl1NfyTvjDEwyoHmwiVBBZ9Kf89R4F56Ssi28Nnmlidesd8qe9Z2IpE6

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.6

-- Started on 2025-12-12 21:18:54

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

ALTER TABLE ONLY public.user_channel DROP CONSTRAINT user_channel_user_id_foreign;
ALTER TABLE ONLY public.user_channel DROP CONSTRAINT user_channel_channel_id_foreign;
ALTER TABLE ONLY public.messages DROP CONSTRAINT messages_sender_id_foreign;
ALTER TABLE ONLY public.messages DROP CONSTRAINT messages_channel_id_foreign;
ALTER TABLE ONLY public.message_mentions DROP CONSTRAINT message_mentions_message_id_foreign;
ALTER TABLE ONLY public.message_mentions DROP CONSTRAINT message_mentions_mentioned_user_id_foreign;
ALTER TABLE ONLY public.kick_logs DROP CONSTRAINT kick_logs_target_user_id_foreign;
ALTER TABLE ONLY public.kick_logs DROP CONSTRAINT kick_logs_kicker_user_id_foreign;
ALTER TABLE ONLY public.kick_logs DROP CONSTRAINT kick_logs_channel_id_foreign;
ALTER TABLE ONLY public.channels DROP CONSTRAINT channels_created_by_foreign;
ALTER TABLE ONLY public.channel_invites DROP CONSTRAINT channel_invites_user_id_foreign;
ALTER TABLE ONLY public.channel_invites DROP CONSTRAINT channel_invites_invited_by_foreign;
ALTER TABLE ONLY public.channel_invites DROP CONSTRAINT channel_invites_channel_id_foreign;
ALTER TABLE ONLY public.channel_bans DROP CONSTRAINT channel_bans_user_id_foreign;
ALTER TABLE ONLY public.channel_bans DROP CONSTRAINT channel_bans_channel_id_foreign;
ALTER TABLE ONLY public.channel_bans DROP CONSTRAINT channel_bans_banned_by_foreign;
ALTER TABLE ONLY public.auth_access_tokens DROP CONSTRAINT auth_access_tokens_tokenable_id_foreign;
ALTER TABLE ONLY public.users DROP CONSTRAINT users_pkey;
ALTER TABLE ONLY public.users DROP CONSTRAINT users_nick_name_unique;
ALTER TABLE ONLY public.user_channel DROP CONSTRAINT user_channel_user_id_channel_id_unique;
ALTER TABLE ONLY public.user_channel DROP CONSTRAINT user_channel_pkey;
ALTER TABLE ONLY public.messages DROP CONSTRAINT messages_pkey;
ALTER TABLE ONLY public.message_mentions DROP CONSTRAINT message_mentions_pkey;
ALTER TABLE ONLY public.kick_logs DROP CONSTRAINT kick_logs_pkey;
ALTER TABLE ONLY public.kick_logs DROP CONSTRAINT kick_logs_channel_id_target_user_id_kicker_user_id_unique;
ALTER TABLE ONLY public.commands DROP CONSTRAINT commands_pkey;
ALTER TABLE ONLY public.channels DROP CONSTRAINT channels_pkey;
ALTER TABLE ONLY public.channel_invites DROP CONSTRAINT channel_invites_pkey;
ALTER TABLE ONLY public.channel_bans DROP CONSTRAINT channel_bans_pkey;
ALTER TABLE ONLY public.channel_bans DROP CONSTRAINT channel_bans_channel_id_user_id_unique;
ALTER TABLE ONLY public.auth_access_tokens DROP CONSTRAINT auth_access_tokens_pkey;
ALTER TABLE ONLY public.adonis_schema_versions DROP CONSTRAINT adonis_schema_versions_pkey;
ALTER TABLE ONLY public.adonis_schema DROP CONSTRAINT adonis_schema_pkey;
ALTER TABLE public.users ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.user_channel ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.messages ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.message_mentions ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.kick_logs ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.commands ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.channels ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.channel_invites ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.channel_bans ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.auth_access_tokens ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.adonis_schema ALTER COLUMN id DROP DEFAULT;
DROP SEQUENCE public.users_id_seq;
DROP TABLE public.users;
DROP SEQUENCE public.user_channel_id_seq;
DROP TABLE public.user_channel;
DROP SEQUENCE public.messages_id_seq;
DROP TABLE public.messages;
DROP SEQUENCE public.message_mentions_id_seq;
DROP TABLE public.message_mentions;
DROP SEQUENCE public.kick_logs_id_seq;
DROP TABLE public.kick_logs;
DROP SEQUENCE public.commands_id_seq;
DROP TABLE public.commands;
DROP SEQUENCE public.channels_id_seq;
DROP TABLE public.channels;
DROP SEQUENCE public.channel_invites_id_seq;
DROP TABLE public.channel_invites;
DROP SEQUENCE public.channel_bans_id_seq;
DROP TABLE public.channel_bans;
DROP SEQUENCE public.auth_access_tokens_id_seq;
DROP TABLE public.auth_access_tokens;
DROP TABLE public.adonis_schema_versions;
DROP SEQUENCE public.adonis_schema_id_seq;
DROP TABLE public.adonis_schema;
SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 218 (class 1259 OID 32332)
-- Name: adonis_schema; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.adonis_schema (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    batch integer NOT NULL,
    migration_time timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.adonis_schema OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 32331)
-- Name: adonis_schema_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.adonis_schema_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.adonis_schema_id_seq OWNER TO postgres;

--
-- TOC entry 4995 (class 0 OID 0)
-- Dependencies: 217
-- Name: adonis_schema_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.adonis_schema_id_seq OWNED BY public.adonis_schema.id;


--
-- TOC entry 219 (class 1259 OID 32339)
-- Name: adonis_schema_versions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.adonis_schema_versions (
    version integer NOT NULL
);


ALTER TABLE public.adonis_schema_versions OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 32443)
-- Name: auth_access_tokens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auth_access_tokens (
    id integer NOT NULL,
    tokenable_id integer NOT NULL,
    type character varying(255) NOT NULL,
    name character varying(255),
    hash character varying(255) NOT NULL,
    abilities text NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    last_used_at timestamp with time zone,
    expires_at timestamp with time zone
);


ALTER TABLE public.auth_access_tokens OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 32442)
-- Name: auth_access_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.auth_access_tokens_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.auth_access_tokens_id_seq OWNER TO postgres;

--
-- TOC entry 4996 (class 0 OID 0)
-- Dependencies: 232
-- Name: auth_access_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.auth_access_tokens_id_seq OWNED BY public.auth_access_tokens.id;


--
-- TOC entry 239 (class 1259 OID 32508)
-- Name: channel_bans; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.channel_bans (
    id integer NOT NULL,
    channel_id integer NOT NULL,
    user_id integer NOT NULL,
    banned_by integer NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.channel_bans OWNER TO postgres;

--
-- TOC entry 238 (class 1259 OID 32507)
-- Name: channel_bans_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.channel_bans_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.channel_bans_id_seq OWNER TO postgres;

--
-- TOC entry 4997 (class 0 OID 0)
-- Dependencies: 238
-- Name: channel_bans_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.channel_bans_id_seq OWNED BY public.channel_bans.id;


--
-- TOC entry 237 (class 1259 OID 32482)
-- Name: channel_invites; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.channel_invites (
    id integer NOT NULL,
    channel_id integer,
    user_id integer,
    invited_by integer,
    status text DEFAULT 'pending'::text,
    created_at timestamp with time zone,
    CONSTRAINT channel_invites_status_check CHECK ((status = ANY (ARRAY['pending'::text, 'accepted'::text, 'rejected'::text])))
);


ALTER TABLE public.channel_invites OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 32481)
-- Name: channel_invites_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.channel_invites_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.channel_invites_id_seq OWNER TO postgres;

--
-- TOC entry 4998 (class 0 OID 0)
-- Dependencies: 236
-- Name: channel_invites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.channel_invites_id_seq OWNED BY public.channel_invites.id;


--
-- TOC entry 225 (class 1259 OID 32366)
-- Name: channels; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.channels (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    type character varying(255) NOT NULL,
    created_by integer,
    last_active_at timestamp with time zone,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.channels OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 32365)
-- Name: channels_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.channels_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.channels_id_seq OWNER TO postgres;

--
-- TOC entry 4999 (class 0 OID 0)
-- Dependencies: 224
-- Name: channels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.channels_id_seq OWNED BY public.channels.id;


--
-- TOC entry 223 (class 1259 OID 32357)
-- Name: commands; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.commands (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    description character varying(255),
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.commands OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 32356)
-- Name: commands_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.commands_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.commands_id_seq OWNER TO postgres;

--
-- TOC entry 5000 (class 0 OID 0)
-- Dependencies: 222
-- Name: commands_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.commands_id_seq OWNED BY public.commands.id;


--
-- TOC entry 235 (class 1259 OID 32457)
-- Name: kick_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kick_logs (
    id integer NOT NULL,
    channel_id integer NOT NULL,
    target_user_id integer NOT NULL,
    kicker_user_id integer NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.kick_logs OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 32456)
-- Name: kick_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.kick_logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.kick_logs_id_seq OWNER TO postgres;

--
-- TOC entry 5001 (class 0 OID 0)
-- Dependencies: 234
-- Name: kick_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.kick_logs_id_seq OWNED BY public.kick_logs.id;


--
-- TOC entry 231 (class 1259 OID 32424)
-- Name: message_mentions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.message_mentions (
    id integer NOT NULL,
    message_id integer NOT NULL,
    mentioned_user_id integer NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.message_mentions OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 32423)
-- Name: message_mentions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.message_mentions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.message_mentions_id_seq OWNER TO postgres;

--
-- TOC entry 5002 (class 0 OID 0)
-- Dependencies: 230
-- Name: message_mentions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.message_mentions_id_seq OWNED BY public.message_mentions.id;


--
-- TOC entry 227 (class 1259 OID 32380)
-- Name: messages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.messages (
    id integer NOT NULL,
    channel_id integer,
    sender_id integer,
    content text,
    has_ping boolean DEFAULT false NOT NULL,
    sent_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.messages OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 32379)
-- Name: messages_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.messages_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.messages_id_seq OWNER TO postgres;

--
-- TOC entry 5003 (class 0 OID 0)
-- Dependencies: 226
-- Name: messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.messages_id_seq OWNED BY public.messages.id;


--
-- TOC entry 229 (class 1259 OID 32401)
-- Name: user_channel; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_channel (
    id integer NOT NULL,
    user_id integer,
    channel_id integer,
    role character varying(255) DEFAULT 'member'::character varying,
    notification_settings character varying(255) DEFAULT 'all'::character varying,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.user_channel OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 32400)
-- Name: user_channel_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_channel_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.user_channel_id_seq OWNER TO postgres;

--
-- TOC entry 5004 (class 0 OID 0)
-- Dependencies: 228
-- Name: user_channel_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_channel_id_seq OWNED BY public.user_channel.id;


--
-- TOC entry 221 (class 1259 OID 32345)
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    first_name character varying(255) NOT NULL,
    last_name character varying(255) NOT NULL,
    nick_name character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    password character varying(255) NOT NULL,
    status character varying(255) DEFAULT 'online'::character varying,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.users OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 32344)
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- TOC entry 5005 (class 0 OID 0)
-- Dependencies: 220
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- TOC entry 4749 (class 2604 OID 32335)
-- Name: adonis_schema id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adonis_schema ALTER COLUMN id SET DEFAULT nextval('public.adonis_schema_id_seq'::regclass);


--
-- TOC entry 4764 (class 2604 OID 32446)
-- Name: auth_access_tokens id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_access_tokens ALTER COLUMN id SET DEFAULT nextval('public.auth_access_tokens_id_seq'::regclass);


--
-- TOC entry 4769 (class 2604 OID 32511)
-- Name: channel_bans id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.channel_bans ALTER COLUMN id SET DEFAULT nextval('public.channel_bans_id_seq'::regclass);


--
-- TOC entry 4767 (class 2604 OID 32485)
-- Name: channel_invites id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.channel_invites ALTER COLUMN id SET DEFAULT nextval('public.channel_invites_id_seq'::regclass);


--
-- TOC entry 4754 (class 2604 OID 32369)
-- Name: channels id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.channels ALTER COLUMN id SET DEFAULT nextval('public.channels_id_seq'::regclass);


--
-- TOC entry 4753 (class 2604 OID 32360)
-- Name: commands id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commands ALTER COLUMN id SET DEFAULT nextval('public.commands_id_seq'::regclass);


--
-- TOC entry 4765 (class 2604 OID 32460)
-- Name: kick_logs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kick_logs ALTER COLUMN id SET DEFAULT nextval('public.kick_logs_id_seq'::regclass);


--
-- TOC entry 4761 (class 2604 OID 32427)
-- Name: message_mentions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.message_mentions ALTER COLUMN id SET DEFAULT nextval('public.message_mentions_id_seq'::regclass);


--
-- TOC entry 4755 (class 2604 OID 32383)
-- Name: messages id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages ALTER COLUMN id SET DEFAULT nextval('public.messages_id_seq'::regclass);


--
-- TOC entry 4758 (class 2604 OID 32404)
-- Name: user_channel id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_channel ALTER COLUMN id SET DEFAULT nextval('public.user_channel_id_seq'::regclass);


--
-- TOC entry 4751 (class 2604 OID 32348)
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- TOC entry 4968 (class 0 OID 32332)
-- Dependencies: 218
-- Data for Name: adonis_schema; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.adonis_schema (id, name, batch, migration_time) FROM stdin;
1	database/migrations/1762344588950_create_users_table	1	2025-12-12 20:29:16.32082+01
2	database/migrations/1762344605039_create_commands_table	1	2025-12-12 20:29:16.33787+01
3	database/migrations/1762344615560_create_channels_table	1	2025-12-12 20:29:16.348077+01
4	database/migrations/1762344623952_create_messages_table	1	2025-12-12 20:29:16.378943+01
5	database/migrations/1762344638688_create_user_channels_table	1	2025-12-12 20:29:16.392304+01
6	database/migrations/1762803535094_create_message_mentions_table	1	2025-12-12 20:29:16.405754+01
7	database/migrations/1763146259964_create_access_tokens_table	1	2025-12-12 20:29:16.417592+01
8	database/migrations/1763815178617_create_kick_logs_table	1	2025-12-12 20:29:16.428424+01
9	database/migrations/1763821670605_create_channel_invites_table	1	2025-12-12 20:29:16.44143+01
10	database/migrations/1764154525409_create_channel_bans_table	1	2025-12-12 20:29:16.455257+01
\.


--
-- TOC entry 4969 (class 0 OID 32339)
-- Dependencies: 219
-- Data for Name: adonis_schema_versions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.adonis_schema_versions (version) FROM stdin;
2
\.


--
-- TOC entry 4983 (class 0 OID 32443)
-- Dependencies: 233
-- Data for Name: auth_access_tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.auth_access_tokens (id, tokenable_id, type, name, hash, abilities, created_at, updated_at, last_used_at, expires_at) FROM stdin;
1	1	auth_token	\N	56a7160dbeac48b0c0f79744f9bb2aefca09e5113962167f9b020cbbbe252374	["*"]	2025-12-12 20:30:00.659+01	2025-12-12 20:30:00.659+01	2025-12-12 20:31:08.293+01	\N
\.


--
-- TOC entry 4989 (class 0 OID 32508)
-- Dependencies: 239
-- Data for Name: channel_bans; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.channel_bans (id, channel_id, user_id, banned_by, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 4987 (class 0 OID 32482)
-- Dependencies: 237
-- Data for Name: channel_invites; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.channel_invites (id, channel_id, user_id, invited_by, status, created_at) FROM stdin;
\.


--
-- TOC entry 4975 (class 0 OID 32366)
-- Dependencies: 225
-- Data for Name: channels; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.channels (id, name, type, created_by, last_active_at, created_at, updated_at) FROM stdin;
1	General	public	1	2025-12-12 20:29:16.665+01	2025-12-12 20:29:16.665+01	2025-12-12 20:29:16.665+01
2	Development	public	2	2025-12-12 20:29:16.665+01	2025-12-12 20:29:16.667+01	2025-12-12 20:29:16.667+01
\.


--
-- TOC entry 4973 (class 0 OID 32357)
-- Dependencies: 223
-- Data for Name: commands; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.commands (id, name, description, created_at, updated_at) FROM stdin;
1	/join channelName [private]	Používateľ vytvorí nový súkromný kanál s názvom channelName. Používateľ, ktorý príkaz zadá, sa stáva správcom kanála.	2025-12-12 20:29:16.653+01	2025-12-12 20:29:16.653+01
2	/join channelName	Pridá používateľa do existujúceho verejného kanála s názvom channelName. Ak kanál neexistuje, automaticky sa vytvorí ako verejný a používateľ sa stáva jeho správcom.	2025-12-12 20:29:16.655+01	2025-12-12 20:29:16.655+01
3	/invite nickName	Pozve používateľa s daným nickName do aktuálneho kanála. V súkromnom kanáli môže pozývať iba správca, vo verejnom ktorýkoľvek člen. Ak má používateľ ban, pozvánka ho môže odblokovať.	2025-12-12 20:29:16.656+01	2025-12-12 20:29:16.656+01
4	/revoke nickName	Odoberie používateľovi s daným nickName prístup do aktuálneho kanála. Tento príkaz je dostupný iba správcovi súkromného kanála.	2025-12-12 20:29:16.657+01	2025-12-12 20:29:16.657+01
5	/kick nickName	Vo verejnom kanáli môžu členovia vyhodiť používateľa. Ak to spravia aspoň 3 členovia, používateľ dostáva trvalý ban. Správca môže používateľa kedykoľvek vyhodiť prístup pomocou /kick	2025-12-12 20:29:16.657+01	2025-12-12 20:29:16.657+01
6	/quit	Zruší aktuálny kanál, ak príkaz vykoná správca. Všetci členovia stratia prístup a názov kanála je opäť voľný.	2025-12-12 20:29:16.658+01	2025-12-12 20:29:16.658+01
7	/cancel	Odstráni používateľa z aktuálneho kanála. Ak príkaz vykoná správca, celý kanál zaniká.	2025-12-12 20:29:16.658+01	2025-12-12 20:29:16.658+01
8	/list	Zobrazí zoznam členov aktuálneho kanála. Prístupný iba používateľom, ktorí sú členmi kanála.	2025-12-12 20:29:16.659+01	2025-12-12 20:29:16.659+01
\.


--
-- TOC entry 4985 (class 0 OID 32457)
-- Dependencies: 235
-- Data for Name: kick_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.kick_logs (id, channel_id, target_user_id, kicker_user_id, created_at) FROM stdin;
\.


--
-- TOC entry 4981 (class 0 OID 32424)
-- Dependencies: 231
-- Data for Name: message_mentions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.message_mentions (id, message_id, mentioned_user_id, created_at, updated_at) FROM stdin;
\.


--
-- TOC entry 4977 (class 0 OID 32380)
-- Dependencies: 227
-- Data for Name: messages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.messages (id, channel_id, sender_id, content, has_ping, sent_at, created_at, updated_at) FROM stdin;
1	1	1	Hey! Just joined this channel. How are things going?	f	2025-12-12 18:29:16.673+01	2025-12-12 20:29:16.677+01	2025-12-12 20:29:16.677+01
2	1	2	Welcome! Things are great, glad to have you here 👋	f	2025-12-12 18:30:16.673+01	2025-12-12 20:29:16.679+01	2025-12-12 20:29:16.679+01
3	1	1	Thanks! So what do you usually discuss here?	f	2025-12-12 18:31:16.673+01	2025-12-12 20:29:16.679+01	2025-12-12 20:29:16.679+01
4	1	2	Mostly tech stuff, but also random topics. Pretty chill atmosphere.	f	2025-12-12 18:32:16.673+01	2025-12-12 20:29:16.68+01	2025-12-12 20:29:16.68+01
5	1	1	Nice! I saw your profile, you work with React?	f	2025-12-12 18:34:16.673+01	2025-12-12 20:29:16.681+01	2025-12-12 20:29:16.681+01
6	1	2	Yeah! Been using it for about 3 years now. How about you?	f	2025-12-12 18:35:16.673+01	2025-12-12 20:29:16.681+01	2025-12-12 20:29:16.681+01
7	1	1	I do mostly backend stuff with Node.js and AdonisJS lately	f	2025-12-12 18:36:16.673+01	2025-12-12 20:29:16.682+01	2025-12-12 20:29:16.682+01
8	1	2	Oh cool! AdonisJS is awesome. How are you finding it?	f	2025-12-12 18:37:16.673+01	2025-12-12 20:29:16.683+01	2025-12-12 20:29:16.683+01
9	1	1	Loving it so far. The structure is really clean and the docs are solid	f	2025-12-12 18:38:16.673+01	2025-12-12 20:29:16.684+01	2025-12-12 20:29:16.684+01
10	1	2	Definitely! The ORM is really nice too. Much better than raw SQL queries everywhere	f	2025-12-12 18:40:16.673+01	2025-12-12 20:29:16.684+01	2025-12-12 20:29:16.684+01
11	1	1	Absolutely. I just finished setting up authentication with Lucid yesterday	f	2025-12-12 18:42:16.673+01	2025-12-12 20:29:16.685+01	2025-12-12 20:29:16.685+01
12	1	2	Nice! Did you use the built-in auth or roll your own?	f	2025-12-12 18:43:16.673+01	2025-12-12 20:29:16.685+01	2025-12-12 20:29:16.685+01
13	1	1	Built-in. No point reinventing the wheel, right?	f	2025-12-12 18:44:16.673+01	2025-12-12 20:29:16.686+01	2025-12-12 20:29:16.686+01
14	1	2	Smart choice. Security is not something to DIY unless you really know what youre doing	f	2025-12-12 18:45:16.673+01	2025-12-12 20:29:16.686+01	2025-12-12 20:29:16.686+01
15	1	1	Exactly my thinking. So what are you working on these days?	f	2025-12-12 18:47:16.673+01	2025-12-12 20:29:16.687+01	2025-12-12 20:29:16.687+01
16	1	2	Building a dashboard for data visualization. Lots of charts and real-time updates	f	2025-12-12 18:48:16.673+01	2025-12-12 20:29:16.687+01	2025-12-12 20:29:16.687+01
17	1	1	Sounds complex! What are you using for the charts?	f	2025-12-12 18:49:16.673+01	2025-12-12 20:29:16.687+01	2025-12-12 20:29:16.687+01
18	1	2	Recharts mostly. Its built on D3 but way easier to use with React	f	2025-12-12 18:50:16.673+01	2025-12-12 20:29:16.688+01	2025-12-12 20:29:16.688+01
19	1	1	Ive heard good things about Recharts. How are you handling the real-time part?	f	2025-12-12 18:52:16.673+01	2025-12-12 20:29:16.688+01	2025-12-12 20:29:16.688+01
20	1	2	WebSockets! Using Socket.io on both ends	f	2025-12-12 18:53:16.673+01	2025-12-12 20:29:16.689+01	2025-12-12 20:29:16.689+01
21	1	1	Classic choice. Does it scale well for your use case?	f	2025-12-12 18:54:16.673+01	2025-12-12 20:29:16.689+01	2025-12-12 20:29:16.689+01
22	1	2	So far so good. Were only at like 200 concurrent users max, so no issues yet	f	2025-12-12 18:56:16.673+01	2025-12-12 20:29:16.69+01	2025-12-12 20:29:16.69+01
23	1	1	That should be fine. If you scale up you might want to look into Redis for pub/sub	f	2025-12-12 18:57:16.673+01	2025-12-12 20:29:16.69+01	2025-12-12 20:29:16.69+01
24	1	2	Yeah Ive been reading about that. Redis Pub/Sub with Socket.io seems like the standard approach	f	2025-12-12 18:59:16.673+01	2025-12-12 20:29:16.691+01	2025-12-12 20:29:16.691+01
25	1	1	It is. Works great for horizontal scaling across multiple server instances	f	2025-12-12 19:01:16.673+01	2025-12-12 20:29:16.691+01	2025-12-12 20:29:16.691+01
26	1	2	Good to know! Hopefully we get to that point where we need it haha	f	2025-12-12 19:02:16.673+01	2025-12-12 20:29:16.692+01	2025-12-12 20:29:16.692+01
27	1	1	Haha thats the dream right? Too many users to handle 😄	f	2025-12-12 19:03:16.673+01	2025-12-12 20:29:16.693+01	2025-12-12 20:29:16.693+01
28	1	2	Exactly! Anyway, I gotta run. Lunch break is over. Catch you later!	f	2025-12-12 19:05:16.673+01	2025-12-12 20:29:16.693+01	2025-12-12 20:29:16.693+01
29	1	1	Sure thing! Thanks for the chat, learned a lot 👍	f	2025-12-12 19:06:16.673+01	2025-12-12 20:29:16.693+01	2025-12-12 20:29:16.693+01
30	1	2	Anytime! Feel free to ping me if you have questions	f	2025-12-12 19:07:16.673+01	2025-12-12 20:29:16.694+01	2025-12-12 20:29:16.694+01
31	2	1	Hey, so I started looking into that bug you mentioned	f	2025-12-12 19:14:16.673+01	2025-12-12 20:29:16.694+01	2025-12-12 20:29:16.694+01
32	2	2	Oh awesome! The one with the user sessions timing out randomly?	f	2025-12-12 19:15:16.673+01	2025-12-12 20:29:16.695+01	2025-12-12 20:29:16.695+01
33	2	1	Yeah that one. I think I found the issue	f	2025-12-12 19:16:16.673+01	2025-12-12 20:29:16.695+01	2025-12-12 20:29:16.695+01
34	2	2	Really? What was it?	f	2025-12-12 19:17:16.673+01	2025-12-12 20:29:16.695+01	2025-12-12 20:29:16.695+01
35	2	1	The session middleware was configured with a 15 minute timeout, but the frontend was polling every 20 minutes	f	2025-12-12 19:18:16.673+01	2025-12-12 20:29:16.697+01	2025-12-12 20:29:16.697+01
36	2	2	Ohhh that makes so much sense! So the session was expiring before the keep-alive	f	2025-12-12 19:19:16.673+01	2025-12-12 20:29:16.698+01	2025-12-12 20:29:16.698+01
37	2	1	Exactly. Simple fix - just changed the polling interval to 10 minutes	f	2025-12-12 19:21:16.673+01	2025-12-12 20:29:16.699+01	2025-12-12 20:29:16.699+01
38	2	2	Perfect. Did you push the fix already?	f	2025-12-12 19:22:16.673+01	2025-12-12 20:29:16.699+01	2025-12-12 20:29:16.699+01
39	2	1	Not yet, wanted to run it by you first. Should I create a PR?	f	2025-12-12 19:23:16.673+01	2025-12-12 20:29:16.7+01	2025-12-12 20:29:16.7+01
40	2	2	Yeah go ahead! Ill review it this afternoon	f	2025-12-12 19:24:16.673+01	2025-12-12 20:29:16.7+01	2025-12-12 20:29:16.7+01
41	2	1	Cool. Also, I was thinking we should add some tests for this	f	2025-12-12 19:26:16.673+01	2025-12-12 20:29:16.701+01	2025-12-12 20:29:16.701+01
42	2	2	Definitely. Can you mock the session timeout in the test?	f	2025-12-12 19:27:16.673+01	2025-12-12 20:29:16.701+01	2025-12-12 20:29:16.701+01
43	2	1	Should be doable. Ill use Jest fake timers to speed up the timeout	f	2025-12-12 19:29:16.673+01	2025-12-12 20:29:16.702+01	2025-12-12 20:29:16.702+01
44	2	2	Smart! That way we dont have to wait 15 actual minutes in the test	f	2025-12-12 19:30:16.673+01	2025-12-12 20:29:16.703+01	2025-12-12 20:29:16.703+01
45	2	1	Exactly. Ill have it done by end of day	f	2025-12-12 19:32:16.673+01	2025-12-12 20:29:16.703+01	2025-12-12 20:29:16.703+01
46	2	2	Awesome. Oh by the way, did you see the Slack message about the deployment?	f	2025-12-12 19:34:16.673+01	2025-12-12 20:29:16.704+01	2025-12-12 20:29:16.704+01
47	2	1	The one about moving to GitHub Actions?	f	2025-12-12 19:35:16.673+01	2025-12-12 20:29:16.705+01	2025-12-12 20:29:16.705+01
48	2	2	Yeah. Apparently they want to sunset our current CI/CD by next month	f	2025-12-12 19:36:16.673+01	2025-12-12 20:29:16.705+01	2025-12-12 20:29:16.705+01
49	2	1	Ugh, more migration work. Have you used GitHub Actions before?	f	2025-12-12 19:38:16.673+01	2025-12-12 20:29:16.706+01	2025-12-12 20:29:16.706+01
50	2	2	A bit. Its actually pretty straightforward. YAML config files	f	2025-12-12 19:39:16.673+01	2025-12-12 20:29:16.707+01	2025-12-12 20:29:16.707+01
51	2	1	Everything is YAML these days lol	f	2025-12-12 19:40:16.673+01	2025-12-12 20:29:16.707+01	2025-12-12 20:29:16.707+01
52	2	2	Haha true. At least its better than XML 😅	f	2025-12-12 19:41:16.673+01	2025-12-12 20:29:16.708+01	2025-12-12 20:29:16.708+01
53	2	1	Fair point. So when do we need to migrate?	f	2025-12-12 19:43:16.673+01	2025-12-12 20:29:16.708+01	2025-12-12 20:29:16.708+01
54	2	2	They said we have until the end of the month, so about 3 weeks	f	2025-12-12 19:44:16.673+01	2025-12-12 20:29:16.709+01	2025-12-12 20:29:16.709+01
55	2	1	That should be enough time. Want to pair on it next week?	f	2025-12-12 19:46:16.673+01	2025-12-12 20:29:16.709+01	2025-12-12 20:29:16.709+01
56	2	2	Yeah lets do that. Tuesday afternoon work for you?	f	2025-12-12 19:47:16.673+01	2025-12-12 20:29:16.709+01	2025-12-12 20:29:16.709+01
57	2	1	Let me check my calendar... yeah Tuesday at 2pm is free	f	2025-12-12 19:49:16.673+01	2025-12-12 20:29:16.71+01	2025-12-12 20:29:16.71+01
58	2	2	Perfect. Ill send you a calendar invite	f	2025-12-12 19:50:16.673+01	2025-12-12 20:29:16.711+01	2025-12-12 20:29:16.711+01
59	2	1	Sounds good. Should we prepare anything beforehand?	f	2025-12-12 19:52:16.673+01	2025-12-12 20:29:16.711+01	2025-12-12 20:29:16.711+01
60	2	2	Maybe look at the GitHub Actions docs? Just to get familiar with the syntax	f	2025-12-12 19:53:16.673+01	2025-12-12 20:29:16.712+01	2025-12-12 20:29:16.712+01
61	2	1	Will do. Ill also document our current pipeline so we know what to migrate	f	2025-12-12 19:55:16.673+01	2025-12-12 20:29:16.712+01	2025-12-12 20:29:16.712+01
62	2	2	Great idea! That will make things much smoother	f	2025-12-12 19:56:16.673+01	2025-12-12 20:29:16.713+01	2025-12-12 20:29:16.713+01
63	2	1	Alright, Im gonna get back to that PR now	f	2025-12-12 19:58:16.673+01	2025-12-12 20:29:16.713+01	2025-12-12 20:29:16.713+01
64	2	2	Cool, ping me when its ready for review!	f	2025-12-12 19:59:16.673+01	2025-12-12 20:29:16.713+01	2025-12-12 20:29:16.713+01
65	1	1	jj	f	2025-12-12 20:30:41.516+01	2025-12-12 20:30:41.519+01	2025-12-12 20:30:41.519+01
66	1	1	what	f	2025-12-12 20:30:50.89+01	2025-12-12 20:30:50.89+01	2025-12-12 20:30:50.89+01
67	1	1	eeeeeee	f	2025-12-12 20:31:04.92+01	2025-12-12 20:31:04.92+01	2025-12-12 20:31:04.92+01
68	1	1	efff	f	2025-12-12 20:31:10.371+01	2025-12-12 20:31:10.372+01	2025-12-12 20:31:10.372+01
69	1	1	haha	f	2025-12-12 20:31:12.72+01	2025-12-12 20:31:12.72+01	2025-12-12 20:31:12.72+01
70	1	1	jolvan	f	2025-12-12 20:31:14.885+01	2025-12-12 20:31:14.886+01	2025-12-12 20:31:14.886+01
71	1	1	XD	f	2025-12-12 20:31:17.134+01	2025-12-12 20:31:17.134+01	2025-12-12 20:31:17.134+01
72	1	1	lalala	f	2025-12-12 20:44:08.539+01	2025-12-12 20:44:08.539+01	2025-12-12 20:44:08.539+01
\.


--
-- TOC entry 4979 (class 0 OID 32401)
-- Dependencies: 229
-- Data for Name: user_channel; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_channel (id, user_id, channel_id, role, notification_settings, created_at, updated_at) FROM stdin;
1	3	2	member	all	2025-12-12 20:29:16.722+01	2025-12-12 20:29:16.722+01
2	2	2	admin	all	2025-12-12 20:29:16.726+01	2025-12-12 20:29:16.726+01
3	1	2	member	all	2025-12-12 20:29:16.727+01	2025-12-12 20:29:16.727+01
4	3	1	member	all	2025-12-12 20:29:16.727+01	2025-12-12 20:29:16.727+01
5	2	1	member	all	2025-12-12 20:29:16.728+01	2025-12-12 20:29:16.728+01
6	1	1	admin	all	2025-12-12 20:29:16.729+01	2025-12-12 20:29:16.729+01
\.


--
-- TOC entry 4971 (class 0 OID 32345)
-- Dependencies: 221
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, first_name, last_name, nick_name, email, password, status, created_at, updated_at) FROM stdin;
1	Adam	Kovacs	adamk	adam@example.com	$argon2id$v=19$m=65536,t=3,p=4$aALDoZOhUjXaogifcmowBQ$/ZRo9TdA/kNWrwfr+0n0BuRITXqT2w7JVOXV5Pcs+kc	online	2025-12-12 20:29:16.536+01	2025-12-12 20:29:16.536+01
2	Bela	Nagy	belus	bela@example.com	$argon2id$v=19$m=65536,t=3,p=4$jSJ1aW97GktFsEHxKhojoQ$i7gy91AxwOLmNjzLlIvBblrY/C1a58QSvb4T1JZvofo	online	2025-12-12 20:29:16.593+01	2025-12-12 20:29:16.593+01
3	Cecilia	Toth	cecilia	cecilia@example.com	$argon2id$v=19$m=65536,t=3,p=4$OxndI2WAI5PaOFr3WxEK8A$iHvNSKCSm+PTFFYLwBaQ8SPyWkdqI21THCVeH3R7tQE	offline	2025-12-12 20:29:16.644+01	2025-12-12 20:29:16.645+01
\.


--
-- TOC entry 5006 (class 0 OID 0)
-- Dependencies: 217
-- Name: adonis_schema_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.adonis_schema_id_seq', 10, true);


--
-- TOC entry 5007 (class 0 OID 0)
-- Dependencies: 232
-- Name: auth_access_tokens_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.auth_access_tokens_id_seq', 1, true);


--
-- TOC entry 5008 (class 0 OID 0)
-- Dependencies: 238
-- Name: channel_bans_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.channel_bans_id_seq', 1, false);


--
-- TOC entry 5009 (class 0 OID 0)
-- Dependencies: 236
-- Name: channel_invites_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.channel_invites_id_seq', 1, false);


--
-- TOC entry 5010 (class 0 OID 0)
-- Dependencies: 224
-- Name: channels_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.channels_id_seq', 2, true);


--
-- TOC entry 5011 (class 0 OID 0)
-- Dependencies: 222
-- Name: commands_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.commands_id_seq', 8, true);


--
-- TOC entry 5012 (class 0 OID 0)
-- Dependencies: 234
-- Name: kick_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.kick_logs_id_seq', 1, false);


--
-- TOC entry 5013 (class 0 OID 0)
-- Dependencies: 230
-- Name: message_mentions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.message_mentions_id_seq', 1, false);


--
-- TOC entry 5014 (class 0 OID 0)
-- Dependencies: 226
-- Name: messages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.messages_id_seq', 72, true);


--
-- TOC entry 5015 (class 0 OID 0)
-- Dependencies: 228
-- Name: user_channel_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_channel_id_seq', 6, true);


--
-- TOC entry 5016 (class 0 OID 0)
-- Dependencies: 220
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 3, true);


--
-- TOC entry 4774 (class 2606 OID 32338)
-- Name: adonis_schema adonis_schema_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adonis_schema
    ADD CONSTRAINT adonis_schema_pkey PRIMARY KEY (id);


--
-- TOC entry 4776 (class 2606 OID 32343)
-- Name: adonis_schema_versions adonis_schema_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.adonis_schema_versions
    ADD CONSTRAINT adonis_schema_versions_pkey PRIMARY KEY (version);


--
-- TOC entry 4794 (class 2606 OID 32450)
-- Name: auth_access_tokens auth_access_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_access_tokens
    ADD CONSTRAINT auth_access_tokens_pkey PRIMARY KEY (id);


--
-- TOC entry 4802 (class 2606 OID 32532)
-- Name: channel_bans channel_bans_channel_id_user_id_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.channel_bans
    ADD CONSTRAINT channel_bans_channel_id_user_id_unique UNIQUE (channel_id, user_id);


--
-- TOC entry 4804 (class 2606 OID 32515)
-- Name: channel_bans channel_bans_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.channel_bans
    ADD CONSTRAINT channel_bans_pkey PRIMARY KEY (id);


--
-- TOC entry 4800 (class 2606 OID 32491)
-- Name: channel_invites channel_invites_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.channel_invites
    ADD CONSTRAINT channel_invites_pkey PRIMARY KEY (id);


--
-- TOC entry 4784 (class 2606 OID 32373)
-- Name: channels channels_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.channels
    ADD CONSTRAINT channels_pkey PRIMARY KEY (id);


--
-- TOC entry 4782 (class 2606 OID 32364)
-- Name: commands commands_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.commands
    ADD CONSTRAINT commands_pkey PRIMARY KEY (id);


--
-- TOC entry 4796 (class 2606 OID 32480)
-- Name: kick_logs kick_logs_channel_id_target_user_id_kicker_user_id_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kick_logs
    ADD CONSTRAINT kick_logs_channel_id_target_user_id_kicker_user_id_unique UNIQUE (channel_id, target_user_id, kicker_user_id);


--
-- TOC entry 4798 (class 2606 OID 32463)
-- Name: kick_logs kick_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kick_logs
    ADD CONSTRAINT kick_logs_pkey PRIMARY KEY (id);


--
-- TOC entry 4792 (class 2606 OID 32431)
-- Name: message_mentions message_mentions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.message_mentions
    ADD CONSTRAINT message_mentions_pkey PRIMARY KEY (id);


--
-- TOC entry 4786 (class 2606 OID 32389)
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id);


--
-- TOC entry 4788 (class 2606 OID 32410)
-- Name: user_channel user_channel_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_channel
    ADD CONSTRAINT user_channel_pkey PRIMARY KEY (id);


--
-- TOC entry 4790 (class 2606 OID 32422)
-- Name: user_channel user_channel_user_id_channel_id_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_channel
    ADD CONSTRAINT user_channel_user_id_channel_id_unique UNIQUE (user_id, channel_id);


--
-- TOC entry 4778 (class 2606 OID 32355)
-- Name: users users_nick_name_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_nick_name_unique UNIQUE (nick_name);


--
-- TOC entry 4780 (class 2606 OID 32353)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 4812 (class 2606 OID 32451)
-- Name: auth_access_tokens auth_access_tokens_tokenable_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_access_tokens
    ADD CONSTRAINT auth_access_tokens_tokenable_id_foreign FOREIGN KEY (tokenable_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 4819 (class 2606 OID 32526)
-- Name: channel_bans channel_bans_banned_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.channel_bans
    ADD CONSTRAINT channel_bans_banned_by_foreign FOREIGN KEY (banned_by) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- TOC entry 4820 (class 2606 OID 32516)
-- Name: channel_bans channel_bans_channel_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.channel_bans
    ADD CONSTRAINT channel_bans_channel_id_foreign FOREIGN KEY (channel_id) REFERENCES public.channels(id) ON DELETE CASCADE;


--
-- TOC entry 4821 (class 2606 OID 32521)
-- Name: channel_bans channel_bans_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.channel_bans
    ADD CONSTRAINT channel_bans_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 4816 (class 2606 OID 32492)
-- Name: channel_invites channel_invites_channel_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.channel_invites
    ADD CONSTRAINT channel_invites_channel_id_foreign FOREIGN KEY (channel_id) REFERENCES public.channels(id) ON DELETE CASCADE;


--
-- TOC entry 4817 (class 2606 OID 32502)
-- Name: channel_invites channel_invites_invited_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.channel_invites
    ADD CONSTRAINT channel_invites_invited_by_foreign FOREIGN KEY (invited_by) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 4818 (class 2606 OID 32497)
-- Name: channel_invites channel_invites_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.channel_invites
    ADD CONSTRAINT channel_invites_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 4805 (class 2606 OID 32374)
-- Name: channels channels_created_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.channels
    ADD CONSTRAINT channels_created_by_foreign FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 4813 (class 2606 OID 32464)
-- Name: kick_logs kick_logs_channel_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kick_logs
    ADD CONSTRAINT kick_logs_channel_id_foreign FOREIGN KEY (channel_id) REFERENCES public.channels(id) ON DELETE CASCADE;


--
-- TOC entry 4814 (class 2606 OID 32474)
-- Name: kick_logs kick_logs_kicker_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kick_logs
    ADD CONSTRAINT kick_logs_kicker_user_id_foreign FOREIGN KEY (kicker_user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 4815 (class 2606 OID 32469)
-- Name: kick_logs kick_logs_target_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kick_logs
    ADD CONSTRAINT kick_logs_target_user_id_foreign FOREIGN KEY (target_user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 4810 (class 2606 OID 32437)
-- Name: message_mentions message_mentions_mentioned_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.message_mentions
    ADD CONSTRAINT message_mentions_mentioned_user_id_foreign FOREIGN KEY (mentioned_user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 4811 (class 2606 OID 32432)
-- Name: message_mentions message_mentions_message_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.message_mentions
    ADD CONSTRAINT message_mentions_message_id_foreign FOREIGN KEY (message_id) REFERENCES public.messages(id) ON DELETE CASCADE;


--
-- TOC entry 4806 (class 2606 OID 32390)
-- Name: messages messages_channel_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_channel_id_foreign FOREIGN KEY (channel_id) REFERENCES public.channels(id) ON DELETE CASCADE;


--
-- TOC entry 4807 (class 2606 OID 32395)
-- Name: messages messages_sender_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.messages
    ADD CONSTRAINT messages_sender_id_foreign FOREIGN KEY (sender_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- TOC entry 4808 (class 2606 OID 32416)
-- Name: user_channel user_channel_channel_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_channel
    ADD CONSTRAINT user_channel_channel_id_foreign FOREIGN KEY (channel_id) REFERENCES public.channels(id) ON DELETE CASCADE;


--
-- TOC entry 4809 (class 2606 OID 32411)
-- Name: user_channel user_channel_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_channel
    ADD CONSTRAINT user_channel_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


-- Completed on 2025-12-12 21:18:55

--
-- PostgreSQL database dump complete
--

\unrestrict SBMMITBWl1NfyTvjDEwyoHmwiVBBZ9Kf89R4F56Ssi28Nnmlidesd8qe9Z2IpE6

