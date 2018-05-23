--
-- PostgreSQL database dump
--

-- Dumped from database version 10.3
-- Dumped by pg_dump version 10.1

-- Started on 2018-05-23 18:38:54

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

SET search_path = public, pg_catalog;

--
-- TOC entry 290 (class 1255 OID 40727)
-- Name: trigger_create_character(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION trigger_create_character() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
NEW.created_at = now();
NEW.modified_at = now();
NEW.expires_at = now();
RETURN NEW;
END;
$$;


--
-- TOC entry 302 (class 1255 OID 40730)
-- Name: trigger_sum_price_transactions(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION trigger_sum_price_transactions() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
   NEW.total_price = NEW.unit_price * NEW.quantity;
   RETURN NEW;
END;
$$;


--
-- TOC entry 294 (class 1255 OID 40729)
-- Name: trigger_update_character(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION trigger_update_character() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
   NEW.modified_at = now();
   NEW.expires_at = now() + NEW.expires_in * interval '1second';
   RETURN NEW;
END;
$$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 198 (class 1259 OID 40721)
-- Name: characters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE characters (
    name text NOT NULL,
    character_id integer NOT NULL,
    access_token text NOT NULL,
    refresh_token text NOT NULL,
    expires_at timestamp(4) with time zone NOT NULL,
    modified_at timestamp(4) with time zone NOT NULL,
    created_at timestamp(4) with time zone NOT NULL,
    expires_in integer NOT NULL,
    client_id text,
    secret_key text
);


--
-- TOC entry 197 (class 1259 OID 40718)
-- Name: transactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE transactions (
    character_id bigint NOT NULL,
    client_id bigint NOT NULL,
    is_buy boolean NOT NULL,
    is_personal boolean NOT NULL,
    journal_ref_id bigint NOT NULL,
    location_id bigint NOT NULL,
    quantity integer NOT NULL,
    transaction_id bigint NOT NULL,
    type_id bigint NOT NULL,
    unit_price double precision NOT NULL,
    total_price double precision,
    date timestamp with time zone
);


--
-- TOC entry 2683 (class 2606 OID 40756)
-- Name: characters pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY characters
    ADD CONSTRAINT pk PRIMARY KEY (character_id);


--
-- TOC entry 2681 (class 2606 OID 41417)
-- Name: transactions unique transaction; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY transactions
    ADD CONSTRAINT "unique transaction" UNIQUE (character_id, client_id, is_buy, is_personal, journal_ref_id, location_id, quantity, transaction_id, type_id, total_price, unit_price, date);


--
-- TOC entry 2679 (class 1259 OID 40767)
-- Name: fki_fk; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX fki_fk ON public.transactions USING btree (character_id);


--
-- TOC entry 2686 (class 2620 OID 40731)
-- Name: characters trigger_create_user; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_create_user BEFORE INSERT ON public.characters FOR EACH ROW EXECUTE PROCEDURE trigger_create_character();


--
-- TOC entry 2685 (class 2620 OID 40752)
-- Name: transactions trigger_sum_price; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_sum_price BEFORE INSERT ON public.transactions FOR EACH ROW EXECUTE PROCEDURE trigger_sum_price_transactions();


--
-- TOC entry 2687 (class 2620 OID 40732)
-- Name: characters trigger_update_user; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_update_user BEFORE UPDATE ON public.characters FOR EACH ROW EXECUTE PROCEDURE trigger_update_character();


--
-- TOC entry 2684 (class 2606 OID 40768)
-- Name: transactions fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY transactions
    ADD CONSTRAINT fk FOREIGN KEY (character_id) REFERENCES characters(character_id);


-- Completed on 2018-05-23 18:38:54

--
-- PostgreSQL database dump complete
--

