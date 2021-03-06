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

INSERT INTO public.accounts VALUES ('GBRPYHIL2CI3FNQ4BXLFMNDLFJUNPU2HY3ZMFSHONUCEOASW7QC7OX2H', 999999959999999600, 4, 0, NULL, '', 'AQAAAA==', 0, 2);
INSERT INTO public.accounts VALUES ('GCXKG6RN4ONIEPCMNFB732A436Z5PNDSRLGWK7GBLCMQLIFO4S7EYWVU', 9999999900, 8589934593, 0, NULL, 'example.com', 'AQAAAA==', 0, 3);
INSERT INTO public.accounts VALUES ('GC23QF2HUE52AMXUFUH3AYJAXXGXXV2VHXYYR6EYXETPKDXZSAW67XO4', 9999999900, 8589934593, 0, NULL, '', 'AQAAAA==', 3, 3);
INSERT INTO public.accounts VALUES ('GA5WBPYA5Y4WAEHXWR2UKO2UO4BUGHUQ74EUPKON2QHV4WRHOIRNKKH2', 9999999800, 8589934594, 0, NULL, 'abc.com', 'AQAAAA==', 1, 3);
INSERT INTO public.accounts VALUES ('GBXGQJWVLWOYHFLVTKWV5FGHA3LNYY2JQKM7OAJAUEQFU6LPCSEFVXON', 9999999800, 8589934594, 0, NULL, '', 'AQAAAA==', 2, 3);


--
-- Data for Name: ban; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: ledgerheaders; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.ledgerheaders VALUES ('9a98223e8c8622746163179b2ffaee0a0758889b5a50c9fa4093bded4a735053', '0000000000000000000000000000000000000000000000000000000000000000', '572a2e32ff248a07b0e70fd1f6d318c1facd20b6cc08c33d5775259868125a16', 1, 0, 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABXKi4y/ySKB7DnD9H20xjB+s0gtswIwz1XdSWYaBJaFgAAAAEN4Lazp2QAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAZAAAAC0F9eEAAAAAZAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA==');
INSERT INTO public.ledgerheaders VALUES ('16efab88a8aa61e828b88ed6927dc6d34da282fbe8faa25e26df2369db98cbac', '9a98223e8c8622746163179b2ffaee0a0758889b5a50c9fa4093bded4a735053', 'd3ba7b87efd75c0ca80ae898fe96d93465455898d858fb75dfb5476858049d8d', 2, 1523247766, 'AAAACZqYIj6MhiJ0YWMXmy/67goHWIibWlDJ+kCTve1Kc1BTxTRGWh5yLV/HyEEZ3r/csqaPpGHdlsO14uqnlq0IwnYAAAAAWsrqlgAAAAIAAAAIAAAAAQAAAAkAAAAIAAAAAwAAJxAAAAAAP3+y2Yo1bFnwdbq5SkW6ZHGyFTUCOM0jd0OrEn834kfTunuH79dcDKgK6Jj+ltk0ZUVYmNhY+3XftUdoWASdjQAAAAIN4Lazp2QAAAAAAAAAAAGQAAAAAAAAAAAAAAAAAAAAZAAAAC0F9eEAAAAnEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA==');
INSERT INTO public.ledgerheaders VALUES ('627d8901ff405c2a8bb06fce9a0b864ba0846b49665c80ded9413fe7cff597e8', '16efab88a8aa61e828b88ed6927dc6d34da282fbe8faa25e26df2369db98cbac', '5b5f3844840b233096492fdcab6f5c615bbbc61f523149a92b86feb56f1392e2', 3, 1523247767, 'AAAACRbvq4ioqmHoKLiO1pJ9xtNNooL76PqiXibfI2nbmMus7GLNE4XU2EAlzeNwrxl8aiQLrZIbxJxcBDT0/BtPdfsAAAAAWsrqlwAAAAAAAAAAgSdYSeN/LwR/v/dSieJwrG0V1RfVIDH+ZXDT6NdUcvRbXzhEhAsjMJZJL9yrb1xhW7vGH1IxSakrhv61bxOS4gAAAAMN4Lazp2QAAAAAAAAAAAPoAAAAAAAAAAAAAAAAAAAAZAAAAC0F9eEAAAAnEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA==');
INSERT INTO public.ledgerheaders VALUES ('323416ba08182131b9d2d16f7dae57067f45c950cf7ca2f8e0f73cbf5f129fd9', '627d8901ff405c2a8bb06fce9a0b864ba0846b49665c80ded9413fe7cff597e8', 'e6921967bc58397a7f19dc9129e7b737af8abade41e476e4bf0c8786eec95595', 4, 1523247768, 'AAAACWJ9iQH/QFwqi7BvzpoLhkughGtJZlyA3tlBP+fP9ZfoxqUD0SsbA2FmkTpUEf2dkfdC25EnLngjBiSNmDzfsS0AAAAAWsrqmAAAAAAAAAAA3z9hmASpL9tAVxktxD3XSOp3itxSvEmM6AUkwBS4ERnmkhlnvFg5en8Z3JEp57c3r4q63kHkduS/DIeG7slVlQAAAAQN4Lazp2QAAAAAAAAAAAPoAAAAAAAAAAAAAAAAAAAAZAAAAC0F9eEAAAAnEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA==');


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

INSERT INTO public.scphistory VALUES ('GDMQBEBO7FS6ZUQDZLMAE7I7PDVPAYND7SSB7IKSO5XVDHBEEU7L6YGS', 2, 'AAAAANkAkC75ZezSA8rYAn0feOrwYaP8pB+hUndvUZwkJT6/AAAAAAAAAAIAAAACAAAAAQAAAEjFNEZaHnItX8fIQRnev9yypo+kYd2Ww7Xi6qeWrQjCdgAAAABayuqWAAAAAgAAAAgAAAABAAAACQAAAAgAAAADAAAnEAAAAAAAAAABPw0TL6hTyr04idv3yp4OGNKXC/NyiuXs7zyPNtnStrYAAABA6D35M+k1W2Kj0SRc+5zTeSigOOnJGv/TbuxgUszYhyDRsOHAL2aU8tGZqUYchggDBHEU5o93VFp1J4FrjHGiBw==');
INSERT INTO public.scphistory VALUES ('GDMQBEBO7FS6ZUQDZLMAE7I7PDVPAYND7SSB7IKSO5XVDHBEEU7L6YGS', 3, 'AAAAANkAkC75ZezSA8rYAn0feOrwYaP8pB+hUndvUZwkJT6/AAAAAAAAAAMAAAACAAAAAQAAADDsYs0ThdTYQCXN43CvGXxqJAutkhvEnFwENPT8G091+wAAAABayuqXAAAAAAAAAAAAAAABPw0TL6hTyr04idv3yp4OGNKXC/NyiuXs7zyPNtnStrYAAABAbB6zlt/YkJ44WHBCHQgE/l/d4eatnrzRDJ9eGx08YAcwTRjltEGAm2L9lMxW029xJmZgcLG0m3R9LVwgOOTAAg==');
INSERT INTO public.scphistory VALUES ('GDMQBEBO7FS6ZUQDZLMAE7I7PDVPAYND7SSB7IKSO5XVDHBEEU7L6YGS', 4, 'AAAAANkAkC75ZezSA8rYAn0feOrwYaP8pB+hUndvUZwkJT6/AAAAAAAAAAQAAAACAAAAAQAAADDGpQPRKxsDYWaROlQR/Z2R90LbkScueCMGJI2YPN+xLQAAAABayuqYAAAAAAAAAAAAAAABPw0TL6hTyr04idv3yp4OGNKXC/NyiuXs7zyPNtnStrYAAABAsexjxhQAgkdPWf5xby7Q91Yt2CJGiLCmNV00bOFzvzXoh1pP2rjSjQgxFFXwrw0B7TP8Z76dy9Tkz0mf6ph2AQ==');


--
-- Data for Name: scpquorums; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.scpquorums VALUES ('3f0d132fa853cabd3889dbf7ca9e0e18d2970bf3728ae5ecef3c8f36d9d2b6b6', 4, 'AAAAAQAAAAEAAAAA2QCQLvll7NIDytgCfR946vBho/ykH6FSd29RnCQlPr8AAAAA');


--
-- Data for Name: signers; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: storestate; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.storestate VALUES ('lastclosedledger                ', '323416ba08182131b9d2d16f7dae57067f45c950cf7ca2f8e0f73cbf5f129fd9');
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
            "snap": "88347702309efab25ce964692caea553f223b384b8e1bbbebd367c0b34ac485c"
        },
        {
            "curr": "ef31a20a398ee73ce22275ea8177786bac54656f33dcc4f3fec60d55ddf163d9",
            "next": {
                "state": 1,
                "output": "88347702309efab25ce964692caea553f223b384b8e1bbbebd367c0b34ac485c"
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
INSERT INTO public.storestate VALUES ('lastscpdata                     ', 'AAAAAgAAAADZAJAu+WXs0gPK2AJ9H3jq8GGj/KQfoVJ3b1GcJCU+vwAAAAAAAAAEAAAAAz8NEy+oU8q9OInb98qeDhjSlwvzcorl7O88jzbZ0ra2AAAAAQAAADDGpQPRKxsDYWaROlQR/Z2R90LbkScueCMGJI2YPN+xLQAAAABayuqYAAAAAAAAAAAAAAABAAAAMMalA9ErGwNhZpE6VBH9nZH3QtuRJy54IwYkjZg837EtAAAAAFrK6pgAAAAAAAAAAAAAAEDPWnzxs2W9gjYRUfBlakg8wLJ+Rt4rUDPnyEdHEWhccPAIa32MgpEoWZ6lOLjcX0uHx3/nUdpb9LLZMGZ2p6EOAAAAANkAkC75ZezSA8rYAn0feOrwYaP8pB+hUndvUZwkJT6/AAAAAAAAAAQAAAACAAAAAQAAADDGpQPRKxsDYWaROlQR/Z2R90LbkScueCMGJI2YPN+xLQAAAABayuqYAAAAAAAAAAAAAAABPw0TL6hTyr04idv3yp4OGNKXC/NyiuXs7zyPNtnStrYAAABAsexjxhQAgkdPWf5xby7Q91Yt2CJGiLCmNV00bOFzvzXoh1pP2rjSjQgxFFXwrw0B7TP8Z76dy9Tkz0mf6ph2AQAAAAFifYkB/0BcKouwb86aC4ZLoIRrSWZcgN7ZQT/nz/WX6AAAAAAAAAABAAAAAQAAAAEAAAAA2QCQLvll7NIDytgCfR946vBho/ykH6FSd29RnCQlPr8AAAAA');


--
-- Data for Name: trustlines; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: txfeehistory; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.txfeehistory VALUES ('b2a227c39c64a44fc7abd4c96819456f0399906d12c476d70b402bfdb296d6a3', 2, 1, 'AAAAAgAAAAMAAAABAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtrOnZAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAACAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtrOnY/+cAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==');
INSERT INTO public.txfeehistory VALUES ('36be70fb7782f9801cdcedc1206e21f99293c99860a15e441f4749747a0a37ab', 2, 2, 'AAAAAgAAAAMAAAACAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtrOnY/+cAAAAAAAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAACAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtrOnY/84AAAAAAAAAAIAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==');
INSERT INTO public.txfeehistory VALUES ('90880ac53815dac8441add0220a7631ef5eac3d57c2e89634ea9b5203f61a8e4', 2, 3, 'AAAAAgAAAAMAAAACAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtrOnY/84AAAAAAAAAAIAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAACAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtrOnY/7UAAAAAAAAAAMAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==');
INSERT INTO public.txfeehistory VALUES ('d55be296c632a0da12694260ee59de3b3056116f308df1b3d867384ba4bc501f', 2, 4, 'AAAAAgAAAAMAAAACAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtrOnY/7UAAAAAAAAAAMAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAACAAAAAAAAAABi/B0L0JGythwN1lY0aypo19NHxvLCyO5tBEcCVvwF9w3gtrOnY/5wAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==');
INSERT INTO public.txfeehistory VALUES ('c54713f50ce473f861155482c2a068e6d10491a6bf973022b5fc799e43668424', 3, 1, 'AAAAAgAAAAMAAAACAAAAAAAAAAA7YL8A7jlgEPe0dUU7VHcDQx6Q/wlHqc3UD15aJ3Ii1QAAAAJUC+QAAAAAAgAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAADAAAAAAAAAAA7YL8A7jlgEPe0dUU7VHcDQx6Q/wlHqc3UD15aJ3Ii1QAAAAJUC+OcAAAAAgAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==');
INSERT INTO public.txfeehistory VALUES ('7566bd8b48d5baf686c899d4f8e732ce16ad1a4a4fdf5bc54c5a5f636dbaf093', 3, 2, 'AAAAAgAAAAMAAAACAAAAAAAAAACuo3ot45qCPExpQ/3oHN+z17Ryis1lfMFYmQWgruS+TAAAAAJUC+QAAAAAAgAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAADAAAAAAAAAACuo3ot45qCPExpQ/3oHN+z17Ryis1lfMFYmQWgruS+TAAAAAJUC+OcAAAAAgAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==');
INSERT INTO public.txfeehistory VALUES ('9583238fc99d27f44f6b60e36110b766f521fbcabb68f09e1dab91c402e30658', 3, 3, 'AAAAAgAAAAMAAAACAAAAAAAAAABuaCbVXZ2DlXWarV6UxwbW3GNJgpn3ASChIFp5bxSIWgAAAAJUC+QAAAAAAgAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAADAAAAAAAAAABuaCbVXZ2DlXWarV6UxwbW3GNJgpn3ASChIFp5bxSIWgAAAAJUC+OcAAAAAgAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==');
INSERT INTO public.txfeehistory VALUES ('303f80a93d90ac54f6c19cba102c15691c5074d0a45bfda94b3cc14841aefba4', 3, 4, 'AAAAAgAAAAMAAAACAAAAAAAAAAC1uBdHoTugMvQtD7BhIL3Ne9dVPfGI+Ji5JvUO+ZAt7wAAAAJUC+QAAAAAAgAAAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAADAAAAAAAAAAC1uBdHoTugMvQtD7BhIL3Ne9dVPfGI+Ji5JvUO+ZAt7wAAAAJUC+OcAAAAAgAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==');
INSERT INTO public.txfeehistory VALUES ('43ce5c493b66081919bc5c4f9a80a4c26756129fc0e7bd3b3d6baa1eaea16720', 3, 5, 'AAAAAgAAAAMAAAADAAAAAAAAAAA7YL8A7jlgEPe0dUU7VHcDQx6Q/wlHqc3UD15aJ3Ii1QAAAAJUC+OcAAAAAgAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAADAAAAAAAAAAA7YL8A7jlgEPe0dUU7VHcDQx6Q/wlHqc3UD15aJ3Ii1QAAAAJUC+M4AAAAAgAAAAIAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==');
INSERT INTO public.txfeehistory VALUES ('e55a573c27be38f6eef4ca4522540e46961f2ddc9b0ea696114380cd95ba4072', 3, 6, 'AAAAAgAAAAMAAAADAAAAAAAAAABuaCbVXZ2DlXWarV6UxwbW3GNJgpn3ASChIFp5bxSIWgAAAAJUC+OcAAAAAgAAAAEAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAEAAAADAAAAAAAAAABuaCbVXZ2DlXWarV6UxwbW3GNJgpn3ASChIFp5bxSIWgAAAAJUC+M4AAAAAgAAAAIAAAAAAAAAAAAAAAAAAAAAAQAAAAAAAAAAAAAAAAAAAA==');


--
-- Data for Name: txhistory; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.txhistory VALUES ('b2a227c39c64a44fc7abd4c96819456f0399906d12c476d70b402bfdb296d6a3', 2, 1, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAABAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAArqN6LeOagjxMaUP96Bzfs9e0corNZXzBWJkFoK7kvkwAAAACVAvkAAAAAAAAAAABVvwF9wAAAEDt3KwmaPuPdFSUxdAFeb6OQetyQKIWazlbSMMhmHKNLD4sqhEqUZcQP0l+X/Op+osWmN6+FUYbsz75Q2jG4vMM', 'sqInw5xkpE/Hq9TJaBlFbwOZkG0SxHbXC0Ar/bKW1qMAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAAAAAAIAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAlQL5AAAAAACAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAIAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2sVNYGnAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA');
INSERT INTO public.txhistory VALUES ('36be70fb7782f9801cdcedc1206e21f99293c99860a15e441f4749747a0a37ab', 2, 2, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAACAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAO2C/AO45YBD3tHVFO1R3A0MekP8JR6nN1A9eWidyItUAAAACVAvkAAAAAAAAAAABVvwF9wAAAEA3xWbxPObnZMiBGFKLJQufJLguTsHJxyAsPP5F9Zj561aXnvN/HVRJbFsEcitGbgi9dWVdKRYvmVWCizIdmLID', 'Nr5w+3eC+YAc3O3BIG4h+ZKTyZhgoV5EH0dJdHoKN6sAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAAAAAAIAAAAAAAAAADtgvwDuOWAQ97R1RTtUdwNDHpD/CUepzdQPXlonciLVAAAAAlQL5AAAAAACAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAIAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2rv9MNnAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA');
INSERT INTO public.txhistory VALUES ('90880ac53815dac8441add0220a7631ef5eac3d57c2e89634ea9b5203f61a8e4', 2, 3, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAADAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAbmgm1V2dg5V1mq1elMcG1txjSYKZ9wEgoSBaeW8UiFoAAAACVAvkAAAAAAAAAAABVvwF9wAAAEBdX4R/Ghzq8/r+u8PL+sNriHsS5lW1Vt+9eCe0nnWMNTzMgcUbarePbrpD2gr8DjVumcmpVH9wG2GXtWvwzXoL', 'kIgKxTgV2shEGt0CIKdjHvXqw9V8LoljTqm1ID9hqOQAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAAAAAAIAAAAAAAAAAG5oJtVdnYOVdZqtXpTHBtbcY0mCmfcBIKEgWnlvFIhaAAAAAlQL5AAAAAACAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAIAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2rKtAUnAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA');
INSERT INTO public.txhistory VALUES ('d55be296c632a0da12694260ee59de3b3056116f308df1b3d867384ba4bc501f', 2, 4, 'AAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3AAAAZAAAAAAAAAAEAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAtbgXR6E7oDL0LQ+wYSC9zXvXVT3xiPiYuSb1DvmQLe8AAAACVAvkAAAAAAAAAAABVvwF9wAAAECCLWxqLddjkFkxGzPyIWRq3DsxF75d7ulJo2ZJxS739M7vVVMPCFDgy7IS8iCmRZ6/65y7IyrJlEEfzJiavYEG', '1VvilsYyoNoSaUJg7lneOzBWEW8wjfGz2Gc4S6S8UB8AAAAAAAAAZAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAAAAAAIAAAAAAAAAALW4F0ehO6Ay9C0PsGEgvc1711U98Yj4mLkm9Q75kC3vAAAAAlQL5AAAAAACAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAIAAAAAAAAAAGL8HQvQkbK2HA3WVjRrKmjX00fG8sLI7m0ERwJW/AX3DeC2qlc0bnAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAA');
INSERT INTO public.txhistory VALUES ('c54713f50ce473f861155482c2a068e6d10491a6bf973022b5fc799e43668424', 3, 1, 'AAAAADtgvwDuOWAQ97R1RTtUdwNDHpD/CUepzdQPXlonciLVAAAAZAAAAAIAAAABAAAAAAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAQAAAAAAAAABAAAAAQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABJ3Ii1QAAAECwVU7Ojr3UXiSyw8iUf82xkuoekJoRZPVPzQD7I5OoxKscFOQxV0gLo8/jjHJ/9WKiGBWSZKXqaaHT+ziK48QM', 'xUcT9Qzkc/hhFVSCwqBo5tEEkaa/lzAitfx5nkNmhCQAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAwAAAAMAAAAAAAAAADtgvwDuOWAQ97R1RTtUdwNDHpD/CUepzdQPXlonciLVAAAAAlQL4zgAAAACAAAAAgAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAMAAAAAAAAAADtgvwDuOWAQ97R1RTtUdwNDHpD/CUepzdQPXlonciLVAAAAAlQL4zgAAAACAAAAAgAAAAAAAAAAAAAAAQAAAAABAAAAAAAAAAAAAAAAAAAA');
INSERT INTO public.txhistory VALUES ('7566bd8b48d5baf686c899d4f8e732ce16ad1a4a4fdf5bc54c5a5f636dbaf093', 3, 2, 'AAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAZAAAAAIAAAABAAAAAAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAQAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAC2V4YW1wbGUuY29tAAAAAAAAAAAAAAAAAa7kvkwAAABAyfE1Bq+ojZFnfczsV/5ZPFNT9FRpeVdjfR8KEX8McvuNFPgKRV32p8p5Rfw+lx3JC/Wo4Ap5bQolJGqNoGeKBw==', 'dWa9i0jVuvaGyJnU+OcyzhatGkpP31vFTFpfY2268JMAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAwAAAAMAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAlQL45wAAAACAAAAAQAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAMAAAAAAAAAAK6jei3jmoI8TGlD/egc37PXtHKKzWV8wViZBaCu5L5MAAAAAlQL45wAAAACAAAAAQAAAAAAAAAAAAAAAAAAAAtleGFtcGxlLmNvbQABAAAAAAAAAAAAAAAAAAAA');
INSERT INTO public.txhistory VALUES ('9583238fc99d27f44f6b60e36110b766f521fbcabb68f09e1dab91c402e30658', 3, 3, 'AAAAAG5oJtVdnYOVdZqtXpTHBtbcY0mCmfcBIKEgWnlvFIhaAAAAZAAAAAIAAAABAAAAAAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAQAAAAAAAAABAAAAAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABbxSIWgAAAEBTN2f3Ze/XH3TWj7Q9wf3r9M7+8ftPryhxFB/A6lwR5ICiidCl24UqDbO153ccgqd3cMsGqCtE6JZywBKQb88L', 'lYMjj8mdJ/RPa2DjYRC3ZvUh+8q7aPCeHauRxALjBlgAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAwAAAAMAAAAAAAAAAG5oJtVdnYOVdZqtXpTHBtbcY0mCmfcBIKEgWnlvFIhaAAAAAlQL4zgAAAACAAAAAgAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAMAAAAAAAAAAG5oJtVdnYOVdZqtXpTHBtbcY0mCmfcBIKEgWnlvFIhaAAAAAlQL4zgAAAACAAAAAgAAAAAAAAAAAAAAAgAAAAABAAAAAAAAAAAAAAAAAAAA');
INSERT INTO public.txhistory VALUES ('303f80a93d90ac54f6c19cba102c15691c5074d0a45bfda94b3cc14841aefba4', 3, 4, 'AAAAALW4F0ehO6Ay9C0PsGEgvc1711U98Yj4mLkm9Q75kC3vAAAAZAAAAAIAAAABAAAAAAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAQAAAAAAAAABAAAAAwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAB+ZAt7wAAAEBzzvdpZTqxPYVXalv5Mxbfw1KQbtHkOweJYU2iEU9qX/9pWN01cGBcA3gLG3pJyo11wbEy6q26Bo4Lq6Mky+cK', 'MD+AqT2QrFT2wZy6ECwVaRxQdNCkW/2pSzzBSEGu+6QAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAwAAAAMAAAAAAAAAALW4F0ehO6Ay9C0PsGEgvc1711U98Yj4mLkm9Q75kC3vAAAAAlQL45wAAAACAAAAAQAAAAAAAAAAAAAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAMAAAAAAAAAALW4F0ehO6Ay9C0PsGEgvc1711U98Yj4mLkm9Q75kC3vAAAAAlQL45wAAAACAAAAAQAAAAAAAAAAAAAAAwAAAAABAAAAAAAAAAAAAAAAAAAA');
INSERT INTO public.txhistory VALUES ('43ce5c493b66081919bc5c4f9a80a4c26756129fc0e7bd3b3d6baa1eaea16720', 3, 5, 'AAAAADtgvwDuOWAQ97R1RTtUdwNDHpD/CUepzdQPXlonciLVAAAAZAAAAAIAAAACAAAAAAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAQAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABAAAAB2FiYy5jb20AAAAAAAAAAAAAAAABJ3Ii1QAAAEDuY9kr4BrzIv7ybk9W51xS4t/bMDP4/flPoFqVZ/mey13NS/nAJ5K0n44FJxx4vuj9W5xDQ97vJ7sAneQ6NZAL', 'Q85cSTtmCBkZvFxPmoCkwmdWEp/A5707PWuqHq6hZyAAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAwAAAAMAAAAAAAAAADtgvwDuOWAQ97R1RTtUdwNDHpD/CUepzdQPXlonciLVAAAAAlQL4zgAAAACAAAAAgAAAAAAAAAAAAAAAQAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAMAAAAAAAAAADtgvwDuOWAQ97R1RTtUdwNDHpD/CUepzdQPXlonciLVAAAAAlQL4zgAAAACAAAAAgAAAAAAAAAAAAAAAQAAAAdhYmMuY29tAAEAAAAAAAAAAAAAAAAAAAA=');
INSERT INTO public.txhistory VALUES ('e55a573c27be38f6eef4ca4522540e46961f2ddc9b0ea696114380cd95ba4072', 3, 6, 'AAAAAG5oJtVdnYOVdZqtXpTHBtbcY0mCmfcBIKEgWnlvFIhaAAAAZAAAAAIAAAACAAAAAAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAQAAAAAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABbxSIWgAAAEAhQmiMSoK3bdG8/cMO3aYhJZWGhRzP9NCVmFSZaWZ7oEp7RysFJShIL2wAw+CYYevaS3VQ4PlG9SblNTLOOh8A', '5VpXPCe+OPbu9MpFIlQORpYfLdybDqaWEUOAzZW6QHIAAAAAAAAAZAAAAAAAAAABAAAAAAAAAAUAAAAAAAAAAA==', 'AAAAAAAAAAEAAAACAAAAAwAAAAMAAAAAAAAAAG5oJtVdnYOVdZqtXpTHBtbcY0mCmfcBIKEgWnlvFIhaAAAAAlQL4zgAAAACAAAAAgAAAAAAAAAAAAAAAgAAAAABAAAAAAAAAAAAAAAAAAAAAAAAAQAAAAMAAAAAAAAAAG5oJtVdnYOVdZqtXpTHBtbcY0mCmfcBIKEgWnlvFIhaAAAAAlQL4zgAAAACAAAAAgAAAAAAAAAAAAAAAgAAAAABAAAAAAAAAAAAAAAAAAAA');


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

