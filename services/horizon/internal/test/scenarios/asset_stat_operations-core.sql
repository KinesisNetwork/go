running recipe
recipe finished, closing ledger
ledger closed
--
-- PostgreSQL database dump
--

-- Dumped from database version 10.3
-- Dumped by pg_dump version 10.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

DROP INDEX IF EXISTS public.signersaccount;
DROP INDEX IF EXISTS public.sellingissuerindex;
DROP INDEX IF EXISTS public.scpquorumsbyseq;
DROP INDEX IF EXISTS public.scpenvsbyseq;
DROP INDEX IF EXISTS public.priceindex;
DROP INDEX IF EXISTS public.ledgersbyseq;
DROP INDEX IF EXISTS public.histfeebyseq;
DROP INDEX IF EXISTS public.histbyseq;
DROP INDEX IF EXISTS public.buyingissuerindex;
DROP INDEX IF EXISTS public.accountbalances;
ALTER TABLE IF EXISTS ONLY public.txhistory DROP CONSTRAINT IF EXISTS txhistory_pkey;
ALTER TABLE IF EXISTS ONLY public.txfeehistory DROP CONSTRAINT IF EXISTS txfeehistory_pkey;
ALTER TABLE IF EXISTS ONLY public.trustlines DROP CONSTRAINT IF EXISTS trustlines_pkey;
ALTER TABLE IF EXISTS ONLY public.storestate DROP CONSTRAINT IF EXISTS storestate_pkey;
ALTER TABLE IF EXISTS ONLY public.signers DROP CONSTRAINT IF EXISTS signers_pkey;
ALTER TABLE IF EXISTS ONLY public.scpquorums DROP CONSTRAINT IF EXISTS scpquorums_pkey;
ALTER TABLE IF EXISTS ONLY public.pubsub DROP CONSTRAINT IF EXISTS pubsub_pkey;
ALTER TABLE IF EXISTS ONLY public.publishqueue DROP CONSTRAINT IF EXISTS publishqueue_pkey;
ALTER TABLE IF EXISTS ONLY public.peers DROP CONSTRAINT IF EXISTS peers_pkey;
ALTER TABLE IF EXISTS ONLY public.offers DROP CONSTRAINT IF EXISTS offers_pkey;
ALTER TABLE IF EXISTS ONLY public.ledgerheaders DROP CONSTRAINT IF EXISTS ledgerheaders_pkey;
ALTER TABLE IF EXISTS ONLY public.ledgerheaders DROP CONSTRAINT IF EXISTS ledgerheaders_ledgerseq_key;
ALTER TABLE IF EXISTS ONLY public.ban DROP CONSTRAINT IF EXISTS ban_pkey;
ALTER TABLE IF EXISTS ONLY public.accounts DROP CONSTRAINT IF EXISTS accounts_pkey;
ALTER TABLE IF EXISTS ONLY public.accountdata DROP CONSTRAINT IF EXISTS accountdata_pkey;
DROP TABLE IF EXISTS public.txhistory;
DROP TABLE IF EXISTS public.txfeehistory;
DROP TABLE IF EXISTS public.trustlines;
DROP TABLE IF EXISTS public.storestate;
DROP TABLE IF EXISTS public.signers;
DROP TABLE IF EXISTS public.scpquorums;
DROP TABLE IF EXISTS public.scphistory;
DROP TABLE IF EXISTS public.pubsub;
DROP TABLE IF EXISTS public.publishqueue;
DROP TABLE IF EXISTS public.peers;
DROP TABLE IF EXISTS public.offers;
DROP TABLE IF EXISTS public.ledgerheaders;
DROP TABLE IF EXISTS public.ban;
DROP TABLE IF EXISTS public.accounts;
DROP TABLE IF EXISTS public.accountdata;
DROP EXTENSION IF EXISTS plpgsql;
DROP SCHEMA IF EXISTS public;
--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA public;


--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: accountdata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.accountdata (
    accountid character varying(56) NOT NULL,
    dataname character varying(64) NOT NULL,
    datavalue character varying(112) NOT NULL,
    lastmodified integer DEFAULT 0 NOT NULL
);


--
-- Name: accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.accounts (
    accountid character varying(56) NOT NULL,
    balance bigint NOT NULL,
    seqnum bigint NOT NULL,
    numsubentries integer NOT NULL,
    inflationdest character varying(56),
    homedomain character varying(32) NOT NULL,
    thresholds text NOT NULL,
    flags integer NOT NULL,
    lastmodified integer NOT NULL,
    CONSTRAINT accounts_balance_check CHECK ((balance >= 0)),
    CONSTRAINT accounts_numsubentries_check CHECK ((numsubentries >= 0))
);


--
-- Name: ban; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ban (
    nodeid character(56) NOT NULL
);


--
-- Name: ledgerheaders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ledgerheaders (
    ledgerhash character(64) NOT NULL,
    prevhash character(64) NOT NULL,
    bucketlisthash character(64) NOT NULL,
    ledgerseq integer,
    closetime bigint NOT NULL,
    data text NOT NULL,
    CONSTRAINT ledgerheaders_closetime_check CHECK ((closetime >= 0)),
    CONSTRAINT ledgerheaders_ledgerseq_check CHECK ((ledgerseq >= 0))
);


--
-- Name: offers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.offers (
    sellerid character varying(56) NOT NULL,
    offerid bigint NOT NULL,
    sellingassettype integer NOT NULL,
    sellingassetcode character varying(12),
    sellingissuer character varying(56),
    buyingassettype integer NOT NULL,
    buyingassetcode character varying(12),
    buyingissuer character varying(56),
    amount bigint NOT NULL,
    pricen integer NOT NULL,
    priced integer NOT NULL,
    price double precision NOT NULL,
    flags integer NOT NULL,
    lastmodified integer NOT NULL,
    CONSTRAINT offers_amount_check CHECK ((amount >= 0)),
    CONSTRAINT offers_offerid_check CHECK ((offerid >= 0))
);


--
-- Name: peers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.peers (
    ip character varying(15) NOT NULL,
    port integer DEFAULT 0 NOT NULL,
    nextattempt timestamp without time zone NOT NULL,
    numfailures integer DEFAULT 0 NOT NULL,
    CONSTRAINT peers_numfailures_check CHECK ((numfailures >= 0)),
    CONSTRAINT peers_port_check CHECK (((port > 0) AND (port <= 65535)))
);


--
-- Name: publishqueue; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.publishqueue (
    ledger integer NOT NULL,
    state text
);


--
-- Name: pubsub; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pubsub (
    resid character(32) NOT NULL,
    lastread integer
);


--
-- Name: scphistory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.scphistory (
    nodeid character(56) NOT NULL,
    ledgerseq integer NOT NULL,
    envelope text NOT NULL,
    CONSTRAINT scphistory_ledgerseq_check CHECK ((ledgerseq >= 0))
);


--
-- Name: scpquorums; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.scpquorums (
    qsethash character(64) NOT NULL,
    lastledgerseq integer NOT NULL,
    qset text NOT NULL,
    CONSTRAINT scpquorums_lastledgerseq_check CHECK ((lastledgerseq >= 0))
);


--
-- Name: signers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.signers (
    accountid character varying(56) NOT NULL,
    publickey character varying(56) NOT NULL,
    weight integer NOT NULL
);


--
-- Name: storestate; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.storestate (
    statename character(32) NOT NULL,
    state text
);


--
-- Name: trustlines; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.trustlines (
    accountid character varying(56) NOT NULL,
    assettype integer NOT NULL,
    issuer character varying(56) NOT NULL,
    assetcode character varying(12) NOT NULL,
    tlimit bigint NOT NULL,
    balance bigint NOT NULL,
    flags integer NOT NULL,
    lastmodified integer NOT NULL,
    CONSTRAINT trustlines_balance_check CHECK ((balance >= 0)),
    CONSTRAINT trustlines_tlimit_check CHECK ((tlimit > 0))
);


--
-- Name: txfeehistory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.txfeehistory (
    txid character(64) NOT NULL,
    ledgerseq integer NOT NULL,
    txindex integer NOT NULL,
    txchanges text NOT NULL,
    CONSTRAINT txfeehistory_ledgerseq_check CHECK ((ledgerseq >= 0))
);


--
-- Name: txhistory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.txhistory (
    txid character(64) NOT NULL,
    ledgerseq integer NOT NULL,
    txindex integer NOT NULL,
    txbody text NOT NULL,
    txresult text NOT NULL,
    txmeta text NOT NULL,
    CONSTRAINT txhistory_ledgerseq_check CHECK ((ledgerseq >= 0))
);


--
-- Data for Name: accountdata; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: accounts; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.accounts VALUES ('GCFZWN3AOVFQM2BZTZX7P47WSI4QMGJC62LILPKODTNDLVKZZNA5BQJ3', 10000000000, 8589934592, 0, NULL, '', 'AQAAAA==', 0, 2);
INSERT INTO public.accounts VALUES ('GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H', 999999959999999600, 4, 0, NULL, '', 'AQAAAA==', 0, 2);
INSERT INTO public.accounts VALUES ('GAB7GMQPJ5YY2E4UJMLNAZPDEUKPK4AAIPRXIZHKZGUIRC6FP2LAQSDN', 10000000000, 8589934592, 0, NULL, '', 'AQAAAA==', 0, 2);
INSERT INTO public.accounts VALUES ('GCSX4PDUZP3BL522ZVMFXCEJ55NKEOHEMII7PSMJZNAAESJ444GSSJMO', 9999999900, 8589934593, 1, NULL, '', 'AQAAAA==', 0, 3);
INSERT INTO public.accounts VALUES ('GCYLTPOU7IVYHHA3XKQF4YB4W4ZWHFERMOQ7K47IWANKNBFBNJJNEOG5', 9999999900, 8589934593, 1, NULL, '', 'AQAAAA==', 0, 3);


--
-- Data for Name: ban; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: ledgerheaders; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.ledgerheaders VALUES ('9a98223e8c8622746163179b2ffaee0a0758889b5a50c9fa4093bded4a735053', '0000000000000000000000000000000000000000000000000000000000000000', '572a2e32ff248a07b0e70fd1f6d318c1facd20b6cc08c33d5775259868125a16', 1, 0, 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABXKi4y/ySKB7DnD9H20xjB+s0gtswIwz1XdSWYaBJaFgAAAAEN4Lazp2QAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAZAAAAC0F9eEAAAAAZAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA==');
INSERT INTO public.ledgerheaders VALUES ('6c30d9c60f6c55426a2c4b26083ee58fac188507fd586d33f418a9ac463f8854', '9a98223e8c8622746163179b2ffaee0a0758889b5a50c9fa4093bded4a735053', '562c729165001e968701b0e1e1b99eed2e06becb5ada16c24905c9f263b5e2b6', 2, 1523238918, 'AAAACZqYIj6MhiJ0YWMXmy/67goHWIibWlDJ+kCTve1Kc1BTMiHjAsUgSFGGskOE8bTus5oMB96WctAt+YW05VG68ccAAAAAWsrIBgAAAAIAAAAIAAAAAQAAAAkAAAAIAAAAAwAAJxAAAAAAi4Ue20vNo0cmNykBLoF1m6yPEvTdv3MfCquWXwc7NpxWLHKRZQAelocBsOHhuZ7tLga+y1raFsJJBcnyY7XitgAAAAIN4Lazp2QAAAAAAAAAAAGQAAAAAAAAAAAAAAAAAAAAZAAAAC0F9eEAAAAnEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA==');
INSERT INTO public.ledgerheaders VALUES ('ff0024c655931f1d51957ae598395e2354d4f64ba8f4e1a067760b0eea64c4b8', '6c30d9c60f6c55426a2c4b26083ee58fac188507fd586d33f418a9ac463f8854', 'f9ca9d123fc2155b3840b4da3031d1b6cd0b53fb3402dbc90b64659a85a6ea11', 3, 1523238919, 'AAAACWww2cYPbFVCaixLJgg+5Y+sGIUH/VhtM/QYqaxGP4hUwJGxXrjgG2xpoGk8FDHDAExw1GK+3j6l/V8WYsqtNc0AAAAAWsrIBwAAAAAAAAAAGnO6IzwGjtGpJsq8MqsmtnvbZASmS8h2AShtuKS+6oj5yp0SP8IVWzhAtNowMdG2zQtT+zQC28kLZGWahabqEQAAAAMN4Lazp2QAAAAAAAAAAAJYAAAAAAAAAAAAAAAAAAAAZAAAAC0F9eEAAAAnEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA==');
INSERT INTO public.ledgerheaders VALUES ('86a2fdcf249695b703b92ad409c56010edd3552b80593603f35affb848406be3', 'ff0024c655931f1d51957ae598395e2354d4f64ba8f4e1a067760b0eea64c4b8', 'c11ed701cd196a64ebadaf71be078cd1b5411d651f0e9bbff49f96cc85fdfd4a', 4, 1523238920, 'AAAACf8AJMZVkx8dUZV65Zg5XiNU1PZLqPThoGd2Cw7qZMS4MC3lEN+lD6tZjXTPhF2aGhh2T59ixWXXSrkium5aOZMAAAAAWsrICAAAAAAAAAAA3z9hmASpL9tAVxktxD3XSOp3itxSvEmM6AUkwBS4ERnBHtcBzRlqZOutr3G+B4zRtUEdZR8Om7/0n5bMhf39SgAAAAQN4Lazp2QAAAAAAAAAAAJYAAAAAAAAAAAAAAAAAAAAZAAAAC0F9eEAAAAnEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA==');


--
-- Data for Name: offers; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: peers; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: publishqueue; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: pubsub; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: scphistory; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.scphistory VALUES ('GDUF53CAERQ5H33AWDZIRHWEZRKDBY46WJL2TZHMHSN6E24DW3B7GXOX', 2, 'AAAAAOhe7EAkYdPvYLDyiJ7EzFQw456yV6nk7Dyb4muDtsPzAAAAAAAAAAIAAAACAAAAAQAAAEgyIeMCxSBIUYayQ4TxtO6zmgwH3pZy0C35hbTlUbrxxwAAAABaysgGAAAAAgAAAAgAAAABAAAACQAAAAgAAAADAAAnEAAAAAAAAAABtzDlm7wLFSeyc3kuSoZN6I6FAwUkdp1rXOri18Pz9PsAAABAAyKAFtnpLxn4TaVJAxLqtdC/Ev8reP2fnm6DS0kYbnbUgQV3nT5FzP8UBgjUjzWJaryWynnykrIjXOEK96YADw==');
INSERT INTO public.scphistory VALUES ('GDUF53CAERQ5H33AWDZIRHWEZRKDBY46WJL2TZHMHSN6E24DW3B7GXOX', 3, 'AAAAAOhe7EAkYdPvYLDyiJ7EzFQw456yV6nk7Dyb4muDtsPzAAAAAAAAAAMAAAACAAAAAQAAADDAkbFeuOAbbGmgaTwUMcMATHDUYr7ePqX9XxZiyq01zQAAAABaysgHAAAAAAAAAAAAAAABtzDlm7wLFSeyc3kuSoZN6I6FAwUkdp1rXOri18Pz9PsAAABAmXS8VnK0q5+DcqRm5t1nHFZ7R9BmC025RSSpdphZvp9L9r9QPMIfczgK1tvKf1TGUHTYvPiVnp0FLzS7W75WBA==');
INSERT INTO public.scphistory VALUES ('GDUF53CAERQ5H33AWDZIRHWEZRKDBY46WJL2TZHMHSN6E24DW3B7GXOX', 4, 'AAAAAOhe7EAkYdPvYLDyiJ7EzFQw456yV6nk7Dyb4muDtsPzAAAAAAAAAAQAAAACAAAAAQAAADAwLeUQ36UPq1mNdM+EXZoaGHZPn2LFZddKuSK6blo5kwAAAABaysgIAAAAAAAAAAAAAAABtzDlm7wLFSeyc3kuSoZN6I6FAwUkdp1rXOri18Pz9PsAAABAgsCVVK6zdfhjN5F/Khy+4uSfPh6pKrUaq2RpYgkIImmH8hR9N11qbua2NeTC8kikeLNM9Db38TX5KoB6aFCbCQ==');


--
-- Data for Name: scpquorums; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.scpquorums VALUES ('b730e59bbc0b1527b273792e4a864de88e85030524769d6b5ceae2d7c3f3f4fb', 4, 'AAAAAQAAAAEAAAAA6F7sQCRh0+9gsPKInsTMVDDjnrJXqeTsPJvia4O2w/MAAAAA');


--
-- Data for Name: signers; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: storestate; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.storestate VALUES ('lastclosedledger                ', '86a2fdcf249695b703b92ad409c56010edd3552b80593603f35affb848406be3');
INSERT INTO public.storestate VALUES ('historyarchivestate             ', '{
    "version": 1,
    "server": "11bdc3d",
    "currentLedger": 4,
    "currentBuckets": [
        {
            "curr": "0000000000000000000000000000000000000000000000000000000000000000",
            "next": {
                "state": 0
            },
            "snap": "b0739dea5e8418957e711155fbbe931924923ba47f85d20d80f1bc5b477b3086"
        },
        {
            "curr": "ef31a20a398ee73ce22275ea8177786bac54656f33dcc4f3fec60d55ddf163d9",
            "next": {
                "state": 1,
                "output": "b0739dea5e8418957e711155fbbe931924923ba47f85d20d80f1bc5b477b3086"
            },
            "snap": "0000000000000000000000000000000000000000000000000000000000000000"
        },
        {
            "curr": "0000000000000000000000000000000000000000000000000000000000000000",
            "next": {
                "state": 0
            },
            "snap": "0000000000000000000000000000000000000000000000000000000000000000"
        },
        {
            "curr": "0000000000000000000000000000000000000000000000000000000000000000",
            "next": {
                "state": 0
            },
            "snap": "0000000000000000000000000000000000000000000000000000000000000000"
        },
        {
            "curr": "0000000000000000000000000000000000000000000000000000000000000000",
            "next": {
                "state": 0
            },
            "snap": "0000000000000000000000000000000000000000000000000000000000000000"
        },
        {
            "curr": "0000000000000000000000000000000000000000000000000000000000000000",
            "next": {
                "state": 0
            },
            "snap": "0000000000000000000000000000000000000000000000000000000000000000"
        },
        {
            "curr": "0000000000000000000000000000000000000000000000000000000000000000",
            "next": {
                "state": 0
            },
            "snap": "0000000000000000000000000000000000000000000000000000000000000000"
        },
        {
            "curr": "0000000000000000000000000000000000000000000000000000000000000000",
            "next": {
                "state": 0
            },
            "snap": "0000000000000000000000000000000000000000000000000000000000000000"
        },
        {
            "curr": "0000000000000000000000000000000000000000000000000000000000000000",
            "next": {
                "state": 0
            },
            "snap": "0000000000000000000000000000000000000000000000000000000000000000"
        },
        {
            "curr": "0000000000000000000000000000000000000000000000000000000000000000",
            "next": {
                "state": 0
            },
            "snap": "0000000000000000000000000000000000000000000000000000000000000000"
        },
        {
            "curr": "0000000000000000000000000000000000000000000000000000000000000000",
            "next": {
                "state": 0
            },
            "snap": "0000000000000000000000000000000000000000000000000000000000000000"
        }
    ]
}');
INSERT INTO public.storestate VALUES ('databaseschema                  ', '5');
INSERT INTO public.storestate VALUES ('networkpassphrase               ', 'Test SDF Network ; September 2015');
INSERT INTO public.storestate VALUES ('forcescponnextlaunch            ', 'false');
INSERT INTO public.storestate VALUES ('ledgerupgrades                  ', '{
    "time": 0,
    "version": {
        "has": false
    },
    "fee": {
        "has": false
    },
    "maxtxsize": {
        "has": false
    },
    "reserve": {
        "has": false
    }
}');
INSERT INTO public.storestate VALUES ('lastscpdata                     ', 'AAAAAgAAAADoXuxAJGHT72Cw8oiexMxUMOOeslep5Ow8m+Jrg7bD8wAAAAAAAAAEAAAAA7cw5Zu8CxUnsnN5LkqGTeiOhQMFJHada1zq4tfD8/T7AAAAAQAAADAwLeUQ36UPq1mNdM+EXZoaGHZPn2LFZddKuSK6blo5kwAAAABaysgIAAAAAAAAAAAAAAABAAAAMDAt5RDfpQ+rWY10z4RdmhoYdk+fYsVl10q5IrpuWjmTAAAAAFrKyAgAAAAAAAAAAAAAAEAmHBvnt8nQ9PrmKdOTOmPa6U5tyb8U2HpIsKOGBaVRIWInnPLq8QU3HXdh21Oley9VedjVEIgGRIeLy/THUu0FAAAAAOhe7EAkYdPvYLDyiJ7EzFQw456yV6nk7Dyb4muDtsPzAAAAAAAAAAQAAAACAAAAAQAAADAwLeUQ36UPq1mNdM+EXZoaGHZPn2LFZddKuSK6blo5kwAAAABaysgIAAAAAAAAAAAAAAABtzDlm7wLFSeyc3kuSoZN6I6FAwUkdp1rXOri18Pz9PsAAABAgsCVVK6zdfhjN5F/Khy+4uSfPh6pKrUaq2RpYgkIImmH8hR9N11qbua2NeTC8kikeLNM9Db38TX5KoB6aFCbCQAAAAH/ACTGVZMfHVGVeuWYOV4jVNT2S6j04aBndgsO6mTEuAAAAAAAAAABAAAAAQAAAAEAAAAA6F7sQCRh0+9gsPKInsTMVDDjnrJXqeTsPJvia4O2w/MAAAAA');


--
-- Data for Name: trustlines; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.trustlines VALUES ('GCSX4PDUZP3BL522ZVMFXCEJ55NKEOHEMII7PSMJZNAAESJ444GSSJMO', 1, 'GAB7GMQPJ5YY2E4UJMLNAZPDEUKPK4AAIPRXIZHKZGUIRC6FP2LAQSDN', 'USD', 9223372036854775807, 0, 1, 3);
INSERT INTO public.trustlines VALUES ('GCYLTPOU7IVYHHA3XKQF4YB4W4ZWHFERMOQ7K47IWANKNBFBNJJNEOG5', 1, 'GCFZWN3AOVFQM2BZTZX7P47WSI4QMGJC62LILPKODTNDLVKZZNA5BQJ3', 'USD', 9223372036854775807, 0, 1, 3);


--
-- Data for Name: txfeehistory; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.txfeehistory VALUES ('c6c673dd3f0f5248f1e2c85bc88daebedafa4de71202bede4980667c10292821', 2, 1, 'AAAAAgAAAAMAAAABAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtrOnZAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAACAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtrOnY/+cAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==');
INSERT INTO public.txfeehistory VALUES ('790c7fd5024a5da930b7cd55ed31bff4dd4a279ee20a2c1fc089e97557573424', 2, 2, 'AAAAAgAAAAMAAAACAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtrOnY/+cAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAACAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtrOnY/84AAAAAAAAAAIAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==');
INSERT INTO public.txfeehistory VALUES ('834f6076a7870b4921347be0a6128487d900fabc1078be433f473b2f3139837f', 2, 3, 'AAAAAgAAAAMAAAACAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtrOnY/84AAAAAAAAAAIAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAACAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtrOnY/7UAAAAAAAAAAMAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==');
INSERT INTO public.txfeehistory VALUES ('ff8874bbd46e02dfe9b47aafd35b817d3f44bf769a0dff0bf73b16e6bc0a33ef', 2, 4, 'AAAAAgAAAAMAAAACAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtrOnY/7UAAAAAAAAAAMAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAACAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtrOnY/5wAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==');
INSERT INTO public.txfeehistory VALUES ('3cb0f6b31e0a73f6c3a316d930f5deb4d9a825abd80310dcf0c587d7e12c7624', 3, 1, 'AAAAAgAAAAMAAAACAAAAAAAAAAClfjx0y/YV91rNWFuIie9aojjkYhH3yYnLQAJJPOcNKQAAAAJUC+QAAAAAAgAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAADAAAAAAAAAAClfjx0y/YV91rNWFuIie9aojjkYhH3yYnLQAJJPOcNKQAAAAJUC+OcAAAAAgAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==');
INSERT INTO public.txfeehistory VALUES ('a407d1e59a681499d7b1af4752df7b73953c631772eb40ca758989b96018d692', 3, 2, 'AAAAAgAAAAMAAAACAAAAAAAAAACwub3U+iuDnBu6oF5gPLczY5SRY6H1c+iwGqaEoWpS0gAAAAJUC+QAAAAAAgAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAADAAAAAAAAAACwub3U+iuDnBu6oF5gPLczY5SRY6H1c+iwGqaEoWpS0gAAAAJUC+OcAAAAAgAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==');


--
-- Data for Name: txhistory; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.txhistory VALUES ('c6c673dd3f0f5248f1e2c85bc88daebedafa4de71202bede4980667c10292821', 2, 1, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAABAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAsLm91Porg5wbuqBeYDy3M2OUkWOh9XPosBqmhKFqUtIAAAACVAvkAAAAAAAAAAABVvwF9wAAAEDr7G099qIL7nPbxze2xCgJGbUVZ4rvCgTyz+zsKbHqYfSJAlqq+1LJAUIH9fbjTjbNObVelKRa90ri/p2RHXIJ', 'xsZz3T8PUkjx4shbyI2uvtr6TecSAr7eSYBmfBApKCEAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAAAAAAIAAAAAAAAAALC5vdT6K4OcG7qgXmA8tzNjlJFjofVz6LAapoShalLSAAAAAlQL5AAAAAACAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAIAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2sVNYGnAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA');
INSERT INTO public.txhistory VALUES ('790c7fd5024a5da930b7cd55ed31bff4dd4a279ee20a2c1fc089e97557573424', 2, 2, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAACAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAApX48dMv2FfdazVhbiInvWqI45GIR98mJy0ACSTznDSkAAAACVAvkAAAAAAAAAAABVvwF9wAAAEAquSOIytKAx1/dElrYoSuRdTbRtVMQvtE9gAa4uM/elgMLXsdxSsar7SZL+p7I/+J8ZIwivYxnGjOXipt5f4UJ', 'eQx/1QJKXakwt81V7TG/9N1KJ57iCiwfwInpdVdXNCQAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAAAAAAIAAAAAAAAAAKV+PHTL9hX3Ws1YW4iJ71qiOORiEffJictAAkk85w0pAAAAAlQL5AAAAAACAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAIAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2rv9MNnAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA');
INSERT INTO public.txhistory VALUES ('834f6076a7870b4921347be0a6128487d900fabc1078be433f473b2f3139837f', 2, 3, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAADAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAi5s3YHVLBmg5nm/38/aSOQYZIvaWhb1OHNo11VnLQdAAAAACVAvkAAAAAAAAAAABVvwF9wAAAEDSRx2tkaPmowO5+GO4a5qEZ6/6BwbkoAK+N9Ad4Ie8Gu6f4XWu7RjxQ7fbuLLW6kipomxVIfFJ8+Tiv5Zd4UME', 'g09gdqeHC0khNHvgphKEh9kA+rwQeL5DP0c7LzE5g38AAAAAAAAAZAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAAAAAAIAAAAAAAAAAIubN2B1SwZoOZ5v9/P2kjkGGSL2loW9ThzaNdVZy0HQAAAAAlQL5AAAAAACAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAIAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2rKtAUnAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA');
INSERT INTO public.txhistory VALUES ('ff8874bbd46e02dfe9b47aafd35b817d3f44bf769a0dff0bf73b16e6bc0a33ef', 2, 4, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAAEAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAA/MyD09xjROUSxbQZeMlFPVwAEPjdGTqyaiIi8V+lggAAAACVAvkAAAAAAAAAAABVvwF9wAAAEABI+RIBTA9OBOHPtApTdYY2ABBRoR55l4dwEYszn8laVt52bZNa+1NfBVuZffVTyHbaww6Q0/sfo2OfF5c0HwN', '/4h0u9RuAt/ptHqv01uBfT9Ev3aaDf8L9zsW5rwKM+8AAAAAAAAAZAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAAAAAAIAAAAAAAAAAAPzMg9PcY0TlEsW0GXjJRT1cABD43Rk6smoiIvFfpYIAAAAAlQL5AAAAAACAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAIAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2qlc0bnAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA');
INSERT INTO public.txhistory VALUES ('3cb0f6b31e0a73f6c3a316d930f5deb4d9a825abd80310dcf0c587d7e12c7624', 3, 1, 'AAAAAKV+PHTL9hX3Ws1YW4iJ71qiOORiEffJictAAkk85w0pAAAAZAAAAAIAAAABAAAAAAAAAAAAAAABAAAAAAAAAAYAAAABVVNEAAAAAAAD8zIPT3GNE5RLFtBl4yUU9XAAQ+N0ZOrJqIiLxX6WCH//////////AAAAAAAAAAE85w0pAAAAQAg9UNSFr/FJwY+2AcE3v2y/U4rds35uDJ88vP8+6lWRxLTZZJfZkkPQhtSG0VZ44HO3OLLML4Mv+pGLhgXomgA=', 'PLD2sx4Kc/bDoxbZMPXetNmoJavYAxDc8MWH1+EsdiQAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAYAAAAAAAAAAA==', 'AAAAAAAAAAEAAAADAAAAAAAAAAMAAAABAAAAAKV+PHTL9hX3Ws1YW4iJ71qiOORiEffJictAAkk85w0pAAAAAVVTRAAAAAAAA/MyD09xjROUSxbQZeMlFPVwAEPjdGTqyaiIi8V+lggAAAAAAAAAAH//////////AAAAAQAAAAAAAAAAAAAAAwAAAAMAAAAAAAAAAKV+PHTL9hX3Ws1YW4iJ71qiOORiEffJictAAkk85w0pAAAAAlQL45wAAAACAAAAAQAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAMAAAAAAAAAAKV+PHTL9hX3Ws1YW4iJ71qiOORiEffJictAAkk85w0pAAAAAlQL45wAAAACAAAAAQAAAAEAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA');
INSERT INTO public.txhistory VALUES ('a407d1e59a681499d7b1af4752df7b73953c631772eb40ca758989b96018d692', 3, 2, 'AAAAALC5vdT6K4OcG7qgXmA8tzNjlJFjofVz6LAapoShalLSAAAAZAAAAAIAAAABAAAAAAAAAAAAAAABAAAAAAAAAAYAAAABVVNEAAAAAACLmzdgdUsGaDmeb/fz9pI5Bhki9paFvU4c2jXVWctB0H//////////AAAAAAAAAAGhalLSAAAAQCnZlvEITlesuWctD/z9XMvJSujWqCYBR5F6tzeyStpEqiQXeyOEtJrGO3ulubYfi4kuwxETF5+CORR/2+0IKA4=', 'pAfR5ZpoFJnXsa9HUt97c5U8Yxdy60DKdYmJuWAY1pIAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAYAAAAAAAAAAA==', 'AAAAAAAAAAEAAAADAAAAAAAAAAMAAAABAAAAALC5vdT6K4OcG7qgXmA8tzNjlJFjofVz6LAapoShalLSAAAAAVVTRAAAAAAAi5s3YHVLBmg5nm/38/aSOQYZIvaWhb1OHNo11VnLQdAAAAAAAAAAAH//////////AAAAAQAAAAAAAAAAAAAAAwAAAAMAAAAAAAAAALC5vdT6K4OcG7qgXmA8tzNjlJFjofVz6LAapoShalLSAAAAAlQL45wAAAACAAAAAQAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAMAAAAAAAAAALC5vdT6K4OcG7qgXmA8tzNjlJFjofVz6LAapoShalLSAAAAAlQL45wAAAACAAAAAQAAAAEAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA');


--
-- Name: accountdata accountdata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accountdata
    ADD CONSTRAINT accountdata_pkey PRIMARY KEY (accountid, dataname);


--
-- Name: accounts accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (accountid);


--
-- Name: ban ban_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ban
    ADD CONSTRAINT ban_pkey PRIMARY KEY (nodeid);


--
-- Name: ledgerheaders ledgerheaders_ledgerseq_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ledgerheaders
    ADD CONSTRAINT ledgerheaders_ledgerseq_key UNIQUE (ledgerseq);


--
-- Name: ledgerheaders ledgerheaders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ledgerheaders
    ADD CONSTRAINT ledgerheaders_pkey PRIMARY KEY (ledgerhash);


--
-- Name: offers offers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.offers
    ADD CONSTRAINT offers_pkey PRIMARY KEY (offerid);


--
-- Name: peers peers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.peers
    ADD CONSTRAINT peers_pkey PRIMARY KEY (ip, port);


--
-- Name: publishqueue publishqueue_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publishqueue
    ADD CONSTRAINT publishqueue_pkey PRIMARY KEY (ledger);


--
-- Name: pubsub pubsub_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pubsub
    ADD CONSTRAINT pubsub_pkey PRIMARY KEY (resid);


--
-- Name: scpquorums scpquorums_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scpquorums
    ADD CONSTRAINT scpquorums_pkey PRIMARY KEY (qsethash);


--
-- Name: signers signers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.signers
    ADD CONSTRAINT signers_pkey PRIMARY KEY (accountid, publickey);


--
-- Name: storestate storestate_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.storestate
    ADD CONSTRAINT storestate_pkey PRIMARY KEY (statename);


--
-- Name: trustlines trustlines_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.trustlines
    ADD CONSTRAINT trustlines_pkey PRIMARY KEY (accountid, issuer, assetcode);


--
-- Name: txfeehistory txfeehistory_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.txfeehistory
    ADD CONSTRAINT txfeehistory_pkey PRIMARY KEY (ledgerseq, txindex);


--
-- Name: txhistory txhistory_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.txhistory
    ADD CONSTRAINT txhistory_pkey PRIMARY KEY (ledgerseq, txindex);


--
-- Name: accountbalances; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX accountbalances ON public.accounts USING btree (balance) WHERE (balance >= 1000000000);


--
-- Name: buyingissuerindex; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX buyingissuerindex ON public.offers USING btree (buyingissuer);


--
-- Name: histbyseq; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX histbyseq ON public.txhistory USING btree (ledgerseq);


--
-- Name: histfeebyseq; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX histfeebyseq ON public.txfeehistory USING btree (ledgerseq);


--
-- Name: ledgersbyseq; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ledgersbyseq ON public.ledgerheaders USING btree (ledgerseq);


--
-- Name: priceindex; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX priceindex ON public.offers USING btree (price);


--
-- Name: scpenvsbyseq; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX scpenvsbyseq ON public.scphistory USING btree (ledgerseq);


--
-- Name: scpquorumsbyseq; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX scpquorumsbyseq ON public.scpquorums USING btree (lastledgerseq);


--
-- Name: sellingissuerindex; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sellingissuerindex ON public.offers USING btree (sellingissuer);


--
-- Name: signersaccount; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX signersaccount ON public.signers USING btree (accountid);


--
-- PostgreSQL database dump complete
--

