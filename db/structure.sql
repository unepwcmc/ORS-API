--
-- PostgreSQL database dump
--

-- Dumped from database version 10.1
-- Dumped by pg_dump version 10.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: tablefunc; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS tablefunc WITH SCHEMA public;


--
-- Name: EXTENSION tablefunc; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION tablefunc IS 'functions that manipulate whole tables, including crosstab';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: questionnaire_parts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE questionnaire_parts (
    id integer NOT NULL,
    questionnaire_id integer,
    part_id integer,
    part_type character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    parent_id integer,
    lft integer,
    rgt integer,
    original_id integer
);


--
-- Name: questionnaire_parts_with_descendents(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION questionnaire_parts_with_descendents(in_questionnaire_id integer) RETURNS SETOF questionnaire_parts
    LANGUAGE sql
    AS $$
  WITH RECURSIVE questionnaire_parts_with_descendents AS (
    SELECT questionnaire_parts.* FROM questionnaire_parts
    WHERE questionnaire_parts.questionnaire_id = in_questionnaire_id
    UNION
    SELECT hi.* FROM questionnaire_parts hi
    JOIN questionnaire_parts_with_descendents h ON h.id = hi.parent_id
  )
  SELECT * FROM questionnaire_parts_with_descendents;
$$;


--
-- Name: squish(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION squish(text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $_$
    SELECT BTRIM(
      regexp_replace(
        regexp_replace($1, U&'\00A0', ' ', 'g'),
        E'\\s+', ' ', 'g'
      )
    );
  $_$;


--
-- Name: FUNCTION squish(text); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION squish(text) IS 'Squishes whitespace characters in a string';


--
-- Name: squish_null(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION squish_null(text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $_$
    SELECT CASE WHEN SQUISH($1) = '' THEN NULL ELSE SQUISH($1) END;
  $_$;


--
-- Name: FUNCTION squish_null(text); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION squish_null(text) IS 'Squishes whitespace characters in a string and returns null for empty string';


--
-- Name: strip_tags(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION strip_tags(text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $_$
    SELECT regexp_replace(regexp_replace($1, E'(?x)<[^>]*?(\s alt \s* = \s* ([\'"]) ([^>]*?) \2) [^>]*? >', E'\3'), E'(?x)(< [^>]*? >)', '', 'g')
  $_$;


--
-- Name: FUNCTION strip_tags(text); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION strip_tags(text) IS 'Strips html tags from string using a regexp.';


--
-- Name: alerts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE alerts (
    id integer NOT NULL,
    deadline_id integer NOT NULL,
    reminder_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: alerts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE alerts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: alerts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE alerts_id_seq OWNED BY alerts.id;


--
-- Name: answer_links; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE answer_links (
    id integer NOT NULL,
    url text NOT NULL,
    description text,
    title character varying(255),
    answer_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: answer_links_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE answer_links_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: answer_links_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE answer_links_id_seq OWNED BY answer_links.id;


--
-- Name: answer_part_matrix_options; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE answer_part_matrix_options (
    id integer NOT NULL,
    answer_part_id integer NOT NULL,
    matrix_answer_option_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    answer_text text,
    matrix_answer_drop_option_id integer
);


--
-- Name: answer_part_matrix_options_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE answer_part_matrix_options_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: answer_part_matrix_options_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE answer_part_matrix_options_id_seq OWNED BY answer_part_matrix_options.id;


--
-- Name: answer_parts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE answer_parts (
    id integer NOT NULL,
    answer_text text,
    answer_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    field_type_type character varying(255),
    field_type_id integer,
    details_text text,
    answer_text_in_english text,
    original_language character varying(255),
    sort_index integer,
    original_id integer
);


--
-- Name: answer_parts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE answer_parts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: answer_parts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE answer_parts_id_seq OWNED BY answer_parts.id;


--
-- Name: answer_type_fields; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE answer_type_fields (
    id integer NOT NULL,
    language character varying(255) NOT NULL,
    help_text text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    is_default_language boolean DEFAULT false NOT NULL,
    answer_type_type character varying(255),
    answer_type_id integer
);


--
-- Name: answer_type_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE answer_type_fields_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: answer_type_fields_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE answer_type_fields_id_seq OWNED BY answer_type_fields.id;


--
-- Name: answers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE answers (
    id integer NOT NULL,
    user_id integer NOT NULL,
    questionnaire_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    other_text text,
    question_id integer NOT NULL,
    looping_identifier character varying(255),
    from_dependent_section boolean DEFAULT false,
    last_editor_id integer,
    loop_item_id integer,
    original_id integer,
    question_answered boolean DEFAULT false
);


--
-- Name: answers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE answers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: answers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE answers_id_seq OWNED BY answers.id;


--
-- Name: matrix_answer_drop_option_fields; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE matrix_answer_drop_option_fields (
    id integer NOT NULL,
    matrix_answer_drop_option_id integer NOT NULL,
    language character varying(255) NOT NULL,
    is_default_language boolean DEFAULT false NOT NULL,
    option_text character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: matrix_answer_drop_options; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE matrix_answer_drop_options (
    id integer NOT NULL,
    matrix_answer_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    original_id integer
);


--
-- Name: api_matrix_answer_drop_options_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW api_matrix_answer_drop_options_view AS
 WITH mado_lngs AS (
         SELECT madof_1.matrix_answer_drop_option_id,
            array_agg(upper((madof_1.language)::text)) AS languages
           FROM matrix_answer_drop_option_fields madof_1
          WHERE ((madof_1.option_text)::text IS NOT NULL)
          GROUP BY madof_1.matrix_answer_drop_option_id
        )
 SELECT mado.id,
    mado.matrix_answer_id,
    madof.option_text,
    upper((madof.language)::text) AS language,
    madof.is_default_language,
    mado_lngs.languages
   FROM ((matrix_answer_drop_options mado
     JOIN matrix_answer_drop_option_fields madof ON ((madof.matrix_answer_drop_option_id = mado.id)))
     JOIN mado_lngs ON ((mado_lngs.matrix_answer_drop_option_id = mado.id)))
  WHERE ((madof.option_text)::text IS NOT NULL);


--
-- Name: matrix_answer_option_fields; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE matrix_answer_option_fields (
    id integer NOT NULL,
    matrix_answer_option_id integer NOT NULL,
    language character varying(255) NOT NULL,
    title text,
    is_default_language boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: matrix_answer_options; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE matrix_answer_options (
    id integer NOT NULL,
    matrix_answer_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    original_id integer
);


--
-- Name: api_matrix_answer_options_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW api_matrix_answer_options_view AS
 WITH mao_lngs AS (
         SELECT maof_1.matrix_answer_option_id,
            array_agg(upper((maof_1.language)::text)) AS languages
           FROM matrix_answer_option_fields maof_1
          WHERE (maof_1.title IS NOT NULL)
          GROUP BY maof_1.matrix_answer_option_id
        )
 SELECT mao.id,
    mao.matrix_answer_id,
    maof.title,
    upper((maof.language)::text) AS language,
    maof.is_default_language,
    mao_lngs.languages
   FROM ((matrix_answer_options mao
     JOIN matrix_answer_option_fields maof ON ((maof.matrix_answer_option_id = mao.id)))
     JOIN mao_lngs ON ((mao_lngs.matrix_answer_option_id = mao.id)))
  WHERE (maof.title IS NOT NULL);


--
-- Name: matrix_answer_queries; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE matrix_answer_queries (
    id integer NOT NULL,
    matrix_answer_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    original_id integer
);


--
-- Name: matrix_answer_query_fields; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE matrix_answer_query_fields (
    id integer NOT NULL,
    matrix_answer_query_id integer NOT NULL,
    language character varying(255) NOT NULL,
    title text,
    is_default_language boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: api_matrix_answer_queries_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW api_matrix_answer_queries_view AS
 WITH maq_lngs AS (
         SELECT maqf_1.matrix_answer_query_id,
            array_agg(upper((maqf_1.language)::text)) AS languages
           FROM matrix_answer_query_fields maqf_1
          WHERE (maqf_1.title IS NOT NULL)
          GROUP BY maqf_1.matrix_answer_query_id
        )
 SELECT maq.id,
    maq.matrix_answer_id,
    maqf.title,
    upper((maqf.language)::text) AS language,
    maqf.is_default_language,
    maq_lngs.languages
   FROM ((matrix_answer_queries maq
     JOIN matrix_answer_query_fields maqf ON ((maqf.matrix_answer_query_id = maq.id)))
     JOIN maq_lngs ON ((maq_lngs.matrix_answer_query_id = maq.id)))
  WHERE (maqf.title IS NOT NULL);


--
-- Name: multi_answer_option_fields; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE multi_answer_option_fields (
    id integer NOT NULL,
    language character varying(255) NOT NULL,
    option_text text,
    multi_answer_option_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    is_default_language boolean DEFAULT false NOT NULL
);


--
-- Name: multi_answer_options; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE multi_answer_options (
    id integer NOT NULL,
    multi_answer_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    details_field boolean DEFAULT false,
    sort_index integer DEFAULT 0 NOT NULL,
    original_id integer
);


--
-- Name: api_multi_answer_options_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW api_multi_answer_options_view AS
 WITH mao_lngs AS (
         SELECT maof_1.multi_answer_option_id,
            array_agg(upper((maof_1.language)::text)) AS languages
           FROM multi_answer_option_fields maof_1
          WHERE (squish_null(maof_1.option_text) IS NOT NULL)
          GROUP BY maof_1.multi_answer_option_id
        )
 SELECT mao.id,
    mao.multi_answer_id,
    mao.sort_index,
    maof.option_text,
    upper((maof.language)::text) AS language,
    maof.is_default_language,
    mao_lngs.languages
   FROM ((multi_answer_options mao
     JOIN multi_answer_option_fields maof ON ((maof.multi_answer_option_id = mao.id)))
     JOIN mao_lngs ON ((mao_lngs.multi_answer_option_id = mao.id)))
  WHERE (squish_null(maof.option_text) IS NOT NULL);


--
-- Name: range_answer_option_fields; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE range_answer_option_fields (
    id integer NOT NULL,
    range_answer_option_id integer NOT NULL,
    option_text character varying(255),
    language character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    is_default_language boolean DEFAULT false NOT NULL
);


--
-- Name: range_answer_options; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE range_answer_options (
    id integer NOT NULL,
    range_answer_id integer NOT NULL,
    sort_index integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    original_id integer
);


--
-- Name: api_range_answer_options_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW api_range_answer_options_view AS
 WITH rao_lngs AS (
         SELECT raof_1.range_answer_option_id,
            array_agg(upper((raof_1.language)::text)) AS languages
           FROM range_answer_option_fields raof_1
          WHERE (squish_null((raof_1.option_text)::text) IS NOT NULL)
          GROUP BY raof_1.range_answer_option_id
        )
 SELECT rao.id,
    rao.range_answer_id,
    rao.sort_index,
    raof.option_text,
    upper((raof.language)::text) AS language,
    raof.is_default_language,
    rao_lngs.languages
   FROM ((range_answer_options rao
     JOIN range_answer_option_fields raof ON ((raof.range_answer_option_id = rao.id)))
     JOIN rao_lngs ON ((rao_lngs.range_answer_option_id = rao.id)))
  WHERE (squish_null((raof.option_text)::text) IS NOT NULL);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE users (
    id integer NOT NULL,
    email character varying(255) NOT NULL,
    persistence_token character varying(255) NOT NULL,
    crypted_password character varying(255) NOT NULL,
    password_salt character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    login_count integer DEFAULT 0 NOT NULL,
    failed_login_count integer DEFAULT 0 NOT NULL,
    last_request_at timestamp without time zone,
    current_login_at timestamp without time zone,
    last_login_at timestamp without time zone,
    current_login_ip character varying(255),
    last_login_ip character varying(255),
    perishable_token character varying(255) DEFAULT ''::character varying NOT NULL,
    single_access_token character varying(255) NOT NULL,
    first_name character varying(255),
    last_name character varying(255),
    creator_id integer DEFAULT 0,
    language character varying(255) DEFAULT 'en'::character varying,
    category character varying(255),
    region text DEFAULT ''::text,
    country text DEFAULT ''::text,
    has_api_access boolean DEFAULT true
);


--
-- Name: api_answers_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW api_answers_view AS
 SELECT answers.id,
    answers.question_id,
    answers.user_id,
    (((users.first_name)::text || ' '::text) || (users.last_name)::text) AS respondent,
    answers.looping_identifier,
    answers.question_answered,
    ap.field_type_type,
    ap.field_type_id,
        CASE
            WHEN ((ap.field_type_type)::text = 'MultiAnswerOption'::text) THEN mao.option_text
            WHEN ((ap.field_type_type)::text = 'RangeAnswerOption'::text) THEN (rao.option_text)::text
            ELSE ap.answer_text
        END AS answer_text,
        CASE
            WHEN ((ap.field_type_type)::text = 'MatrixAnswerQuery'::text) THEN ( SELECT row_to_json(matrix.*) AS row_to_json
               FROM ( SELECT maq.title AS query,
                        mxao.title AS option,
                            CASE
                                WHEN (apmo.matrix_answer_drop_option_id IS NOT NULL) THEN (mado.option_text)::text
                                ELSE COALESCE(apmo.answer_text, mxao.title)
                            END AS answer) matrix)
            ELSE NULL::json
        END AS matrix_answer,
        CASE
            WHEN ((ap.field_type_type)::text = 'MultiAnswerOption'::text) THEN mao.language
            WHEN ((ap.field_type_type)::text = 'RangeAnswerOption'::text) THEN rao.language
            WHEN ((ap.field_type_type)::text = 'MatrixAnswerQuery'::text) THEN maq.language
            ELSE ''::text
        END AS language,
    ap.details_text,
    ap.answer_text_in_english
   FROM ((((((((answers
     JOIN answer_parts ap ON ((ap.answer_id = answers.id)))
     JOIN users ON ((users.id = answers.user_id)))
     LEFT JOIN api_multi_answer_options_view mao ON (((mao.id = ap.field_type_id) AND ((ap.field_type_type)::text = 'MultiAnswerOption'::text))))
     LEFT JOIN api_range_answer_options_view rao ON (((rao.id = ap.field_type_id) AND ((ap.field_type_type)::text = 'RangeAnswerOption'::text))))
     LEFT JOIN answer_part_matrix_options apmo ON (((apmo.answer_part_id = ap.id) AND ((ap.field_type_type)::text = 'MatrixAnswerQuery'::text))))
     LEFT JOIN api_matrix_answer_queries_view maq ON ((maq.id = ap.field_type_id)))
     LEFT JOIN api_matrix_answer_drop_options_view mado ON (((mado.id = apmo.matrix_answer_drop_option_id) AND (mado.language = maq.language))))
     LEFT JOIN api_matrix_answer_options_view mxao ON (((apmo.matrix_answer_option_id = mxao.id) AND (mxao.language = maq.language))));


--
-- Name: questionnaire_fields; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE questionnaire_fields (
    id integer NOT NULL,
    language character varying(255) NOT NULL,
    title text,
    questionnaire_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    introductory_remarks text,
    is_default_language boolean DEFAULT false NOT NULL,
    email_subject character varying(255) DEFAULT 'Online Reporting System'::character varying,
    email text,
    email_footer character varying(255),
    submit_info_tip text
);


--
-- Name: questionnaires; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE questionnaires (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    last_edited timestamp without time zone,
    user_id integer NOT NULL,
    last_editor_id integer,
    activated_at timestamp without time zone,
    administrator_remarks text,
    questionnaire_date date,
    header_file_name character varying(255),
    header_content_type character varying(255),
    header_file_size integer,
    header_updated_at timestamp without time zone,
    status integer DEFAULT 0,
    display_in_tab_max_level character varying(255) DEFAULT '3'::character varying,
    delegation_enabled boolean DEFAULT true,
    help_pages character varying(255),
    translator_visible boolean DEFAULT false,
    private_documents boolean DEFAULT true,
    original_id integer,
    enable_super_delegates boolean DEFAULT true
);


--
-- Name: api_questionnaires_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW api_questionnaires_view AS
 WITH q_lngs AS (
         SELECT questionnaire_fields.questionnaire_id,
            array_agg(upper((questionnaire_fields.language)::text)) AS languages,
            max(
                CASE
                    WHEN questionnaire_fields.is_default_language THEN upper((questionnaire_fields.language)::text)
                    ELSE NULL::text
                END) AS default_language
           FROM questionnaire_fields
          GROUP BY questionnaire_fields.questionnaire_id
        )
 SELECT q.id,
    (q.created_at)::date AS created_on,
    (q.activated_at)::date AS activated_on,
    q.questionnaire_date,
        CASE
            WHEN (q.status = 0) THEN 'Inactive'::text
            WHEN (q.status = 1) THEN 'Active'::text
            WHEN (q.status = 2) THEN 'Closed'::text
            ELSE 'Unknown'::text
        END AS status,
    upper((qf.language)::text) AS language,
    qf.title,
    qf.is_default_language,
    q_lngs.languages,
    q_lngs.default_language
   FROM ((questionnaires q
     JOIN questionnaire_fields qf ON ((qf.questionnaire_id = q.id)))
     JOIN q_lngs ON ((q_lngs.questionnaire_id = q.id)));


--
-- Name: section_fields; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE section_fields (
    id integer NOT NULL,
    title text,
    language character varying(255) NOT NULL,
    description text,
    section_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    is_default_language boolean DEFAULT false NOT NULL,
    tab_title text
);


--
-- Name: sections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE sections (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    last_edited timestamp without time zone,
    section_type integer NOT NULL,
    answer_type_id integer,
    answer_type_type character varying(255),
    loop_source_id integer,
    loop_item_type_id integer,
    depends_on_option_id integer,
    depends_on_option_value boolean DEFAULT true,
    depends_on_question_id integer,
    is_hidden boolean DEFAULT false,
    starts_collapsed boolean DEFAULT false,
    display_in_tab boolean DEFAULT false,
    original_id integer
);


--
-- Name: api_sections_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW api_sections_view AS
 WITH s_lngs AS (
         SELECT section_fields_1.section_id,
            array_agg(upper((section_fields_1.language)::text)) AS languages
           FROM section_fields section_fields_1
          WHERE (squish_null(section_fields_1.title) IS NOT NULL)
          GROUP BY section_fields_1.section_id
        )
 SELECT sections.id,
    sections.section_type,
    sections.loop_source_id,
    sections.loop_item_type_id,
    sections.depends_on_question_id,
    sections.depends_on_option_id,
    sections.depends_on_option_value,
    sections.is_hidden,
    sections.display_in_tab,
    strip_tags(section_fields.title) AS title,
    upper((section_fields.language)::text) AS language,
    section_fields.is_default_language,
    section_fields.tab_title,
    s_lngs.languages
   FROM ((sections
     JOIN section_fields ON ((sections.id = section_fields.section_id)))
     JOIN s_lngs ON ((s_lngs.section_id = sections.id)))
  WHERE (squish_null(section_fields.title) IS NOT NULL)
  ORDER BY sections.id;


--
-- Name: api_sections_tree_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW api_sections_tree_view AS
 WITH RECURSIVE section_qparts_with_descendents AS (
         SELECT h.questionnaire_id,
            h.id AS qp_id,
            h.parent_id AS qp_parent_id,
            ARRAY[s.title] AS path,
            s.id,
            NULL::integer AS parent_id,
            s.section_type,
            s.loop_source_id,
            s.loop_item_type_id,
                CASE
                    WHEN (s.loop_item_type_id IS NOT NULL) THEN s.id
                    ELSE NULL::integer
                END AS looping_section_id,
            s.depends_on_question_id,
            s.depends_on_option_id,
            s.depends_on_option_value,
            s.is_hidden,
            s.display_in_tab,
            s.title,
            s.language,
            s.is_default_language,
            s.tab_title,
            s.languages
           FROM (questionnaire_parts h
             JOIN api_sections_view s ON (((h.part_id = s.id) AND ((h.part_type)::text = 'Section'::text))))
          WHERE (h.parent_id IS NULL)
        UNION
         SELECT h.questionnaire_id,
            hi.id AS qp_id,
            hi.parent_id AS qp_parent_id,
            (h.path || ARRAY[s.title]),
            s.id,
            h.id AS parent_id,
            s.section_type,
            s.loop_source_id,
            COALESCE(s.loop_item_type_id, h.loop_item_type_id) AS "coalesce",
            COALESCE(
                CASE
                    WHEN (s.loop_item_type_id IS NOT NULL) THEN s.id
                    ELSE NULL::integer
                END, h.looping_section_id) AS "coalesce",
            s.depends_on_question_id,
            s.depends_on_option_id,
            s.depends_on_option_value,
            s.is_hidden,
            s.display_in_tab,
            s.title,
            s.language,
            s.is_default_language,
            s.tab_title,
            s.languages
           FROM ((questionnaire_parts hi
             JOIN api_sections_view s ON (((hi.part_id = s.id) AND ((hi.part_type)::text = 'Section'::text))))
             JOIN section_qparts_with_descendents h ON (((h.qp_id = hi.parent_id) AND (h.language = s.language))))
        )
 SELECT qp.questionnaire_id,
    qp.qp_id,
    qp.qp_parent_id,
    qp.path,
    qp.id,
    qp.parent_id,
    qp.section_type,
    qp.loop_source_id,
    qp.loop_item_type_id,
    qp.looping_section_id,
    qp.depends_on_question_id,
    qp.depends_on_option_id,
    qp.depends_on_option_value,
    qp.is_hidden,
    qp.display_in_tab,
    qp.title,
    qp.language,
    qp.is_default_language,
    qp.tab_title,
    qp.languages
   FROM section_qparts_with_descendents qp;


--
-- Name: loop_item_name_fields; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE loop_item_name_fields (
    id integer NOT NULL,
    language character varying(255) NOT NULL,
    item_name text NOT NULL,
    is_default_language boolean DEFAULT false NOT NULL,
    loop_item_name_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: loop_item_names; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE loop_item_names (
    id integer NOT NULL,
    loop_source_id integer NOT NULL,
    loop_item_type_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    original_id integer
);


--
-- Name: loop_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE loop_items (
    id integer NOT NULL,
    parent_id integer,
    lft integer,
    rgt integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    loop_item_type_id integer NOT NULL,
    sort_index integer DEFAULT 0,
    loop_item_name_id integer,
    original_id integer
);


--
-- Name: api_sections_looping_contexts_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW api_sections_looping_contexts_view AS
 WITH RECURSIVE li_tree(li_id, li_parent_id, section_id, li_lft, li_context, lin_context, language) AS (
         SELECT li.id,
            li.parent_id,
            s_1.id,
            li.lft,
            ARRAY[li.id] AS "array",
            ARRAY[linf.item_name] AS "array",
            upper((linf.language)::text) AS upper
           FROM (((loop_items li
             JOIN sections s_1 ON ((s_1.loop_item_type_id = li.loop_item_type_id)))
             JOIN loop_item_names lin ON ((lin.id = li.loop_item_name_id)))
             JOIN loop_item_name_fields linf ON ((linf.loop_item_name_id = lin.id)))
          WHERE (li.parent_id IS NULL)
        UNION ALL
         SELECT li.id,
            li.parent_id,
            s_1.id,
            li.lft,
            (li_tree_1.li_context || ARRAY[li.id]),
            (li_tree_1.lin_context || ARRAY[linf.item_name]),
            upper((linf.language)::text) AS upper
           FROM ((((loop_items li
             JOIN li_tree li_tree_1 ON ((li.parent_id = li_tree_1.li_id)))
             JOIN sections s_1 ON ((s_1.loop_item_type_id = li.loop_item_type_id)))
             JOIN loop_item_names lin ON ((lin.id = li.loop_item_name_id)))
             JOIN loop_item_name_fields linf ON (((linf.loop_item_name_id = lin.id) AND (upper((linf.language)::text) = li_tree_1.language))))
        )
 SELECT s.id AS section_id,
    s.language,
    array_to_string(li_tree.li_context, 'S'::text) AS looping_identifier,
    li_tree.lin_context AS looping_context,
    li_tree.li_lft
   FROM (api_sections_tree_view s
     JOIN li_tree ON (((s.looping_section_id = li_tree.section_id) AND (s.language = li_tree.language))));


--
-- Name: questions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE questions (
    id integer NOT NULL,
    uidentifier character varying(255),
    last_edited timestamp without time zone,
    section_id integer NOT NULL,
    answer_type_id integer,
    answer_type_type character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    is_mandatory boolean DEFAULT false,
    allow_attachments boolean DEFAULT true,
    original_id integer
);


--
-- Name: api_questions_looping_contexts_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW api_questions_looping_contexts_view AS
 SELECT questions.id AS question_id,
    slc.section_id,
    slc.looping_identifier,
    slc.looping_context,
    slc.li_lft,
    slc.language
   FROM (api_sections_looping_contexts_view slc
     JOIN questions ON ((slc.section_id = questions.section_id)));


--
-- Name: question_fields; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE question_fields (
    id integer NOT NULL,
    language character varying(255) NOT NULL,
    title text,
    short_title character varying(255),
    description text,
    question_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    is_default_language boolean DEFAULT false NOT NULL
);


--
-- Name: api_questions_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW api_questions_view AS
 WITH q_lngs AS (
         SELECT question_fields_1.question_id,
            array_agg(upper((question_fields_1.language)::text)) AS languages
           FROM question_fields question_fields_1
          WHERE (squish_null(question_fields_1.title) IS NOT NULL)
          GROUP BY question_fields_1.question_id
        )
 SELECT questions.id,
    questions.section_id,
    questions.answer_type_id,
    questions.answer_type_type,
    questions.is_mandatory,
    upper((question_fields.language)::text) AS language,
    question_fields.is_default_language,
    strip_tags(question_fields.title) AS title,
    strip_tags((question_fields.short_title)::text) AS short_title,
    strip_tags(question_fields.description) AS description,
    qp.lft,
    q_lngs.languages
   FROM (((questions
     JOIN question_fields ON ((questions.id = question_fields.question_id)))
     JOIN questionnaire_parts qp ON ((((qp.part_type)::text = 'Question'::text) AND (qp.part_id = questions.id))))
     JOIN q_lngs ON ((q_lngs.question_id = questions.id)))
  WHERE (((questions.answer_type_type)::text = ANY (ARRAY[('MultiAnswer'::character varying)::text, ('RangeAnswer'::character varying)::text, ('NumericAnswer'::character varying)::text, ('MatrixAnswer'::character varying)::text])) AND (squish_null(question_fields.title) IS NOT NULL));


--
-- Name: api_questions_tree_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW api_questions_tree_view AS
 WITH mao_options AS (
         SELECT mao.multi_answer_id,
            mao.language,
            array_agg(mao.option_text ORDER BY mao.sort_index) AS options
           FROM api_multi_answer_options_view mao
          GROUP BY mao.multi_answer_id, mao.language
        ), rao_options AS (
         SELECT rao.range_answer_id,
            rao.language,
            array_agg(rao.option_text ORDER BY rao.sort_index) AS options
           FROM api_range_answer_options_view rao
          GROUP BY rao.range_answer_id, rao.language
        ), mxao_options AS (
         SELECT mxao.matrix_answer_id,
            mxao.language,
            array_agg(mxao.title) AS options
           FROM api_matrix_answer_options_view mxao
          GROUP BY mxao.matrix_answer_id, mxao.language
        ), mado_options AS (
         SELECT mado.matrix_answer_id,
            mado.language,
            array_agg(mado.option_text) AS options
           FROM api_matrix_answer_drop_options_view mado
          GROUP BY mado.matrix_answer_id, mado.language
        )
 SELECT q.id,
    q.section_id,
    q.answer_type_id,
    q.answer_type_type,
    q.is_mandatory,
    q.language,
    q.is_default_language,
    q.title,
    q.short_title,
    q.description,
    q.lft,
    q.languages,
    s.questionnaire_id,
    s.section_type,
    s.loop_source_id,
    s.loop_item_type_id,
    s.looping_section_id,
    s.depends_on_question_id,
    s.depends_on_option_id,
    s.depends_on_option_value,
    s.is_hidden,
    s.display_in_tab,
    s.title AS section_title,
    s.tab_title AS section_tab_title,
    s.language AS section_language,
    s.is_default_language AS section_is_default_language,
    s.path,
    COALESCE(mao_options.options, (rao_options.options)::text[], (mado_options.options)::text[], mxao_options.options) AS options
   FROM (((((api_questions_view q
     JOIN api_sections_tree_view s ON (((q.section_id = s.id) AND ((q.language = s.language) OR (s.is_default_language AND (NOT (s.languages @> ARRAY[q.language])))))))
     LEFT JOIN mao_options ON (((mao_options.multi_answer_id = q.answer_type_id) AND ((q.answer_type_type)::text = 'MultiAnswer'::text) AND (mao_options.language = q.language))))
     LEFT JOIN rao_options ON (((rao_options.range_answer_id = q.answer_type_id) AND ((q.answer_type_type)::text = 'RangeAnswer'::text) AND (rao_options.language = q.language))))
     LEFT JOIN mxao_options ON (((mxao_options.matrix_answer_id = q.answer_type_id) AND ((q.answer_type_type)::text = 'MatrixAnswer'::text) AND (mxao_options.language = q.language))))
     LEFT JOIN mado_options ON (((mado_options.matrix_answer_id = q.answer_type_id) AND ((q.answer_type_type)::text = 'MatrixAnswer'::text) AND (mado_options.language = q.language))));


--
-- Name: api_respondents_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW api_respondents_view AS
SELECT
    NULL::integer AS id,
    NULL::integer AS user_id,
    NULL::integer AS questionnaire_id,
    NULL::text AS full_name,
    NULL::text AS status,
    NULL::integer AS status_code,
    NULL::character varying(255) AS language,
    NULL::text AS country,
    NULL::text AS region,
    NULL::character varying[] AS roles;


--
-- Name: application_profiles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE application_profiles (
    id integer NOT NULL,
    title_en character varying(255) DEFAULT ''::character varying,
    short_title_en character varying(255) DEFAULT ''::character varying,
    logo_url text DEFAULT ''::text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    logo_file_name character varying(255),
    logo_content_type character varying(255),
    logo_file_size integer,
    logo_updated_at timestamp without time zone,
    sub_title_en character varying(255) DEFAULT ''::character varying,
    show_sign_up boolean DEFAULT true,
    title_fr character varying(255) DEFAULT ''::character varying,
    title_es character varying(255) DEFAULT ''::character varying,
    short_title_fr character varying(255) DEFAULT ''::character varying,
    short_title_es character varying(255) DEFAULT ''::character varying,
    sub_title_fr character varying(255) DEFAULT ''::character varying,
    sub_title_es character varying(255) DEFAULT ''::character varying
);


--
-- Name: application_profiles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE application_profiles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: application_profiles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE application_profiles_id_seq OWNED BY application_profiles.id;


--
-- Name: assignments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE assignments (
    id integer NOT NULL,
    user_id integer NOT NULL,
    role_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: assignments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE assignments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: assignments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE assignments_id_seq OWNED BY assignments.id;


--
-- Name: authorized_submitters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE authorized_submitters (
    id integer NOT NULL,
    user_id integer NOT NULL,
    questionnaire_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    status integer DEFAULT 0,
    language character varying(255) DEFAULT 'en'::character varying,
    total_questions integer DEFAULT 0,
    answered_questions integer DEFAULT 0,
    requested_unsubmission boolean DEFAULT false
);


--
-- Name: authorized_submitters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE authorized_submitters_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: authorized_submitters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE authorized_submitters_id_seq OWNED BY authorized_submitters.id;


--
-- Name: csv_files; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE csv_files (
    id integer NOT NULL,
    name character varying(255),
    location character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    entity_type character varying(255),
    entity_id integer
);


--
-- Name: csv_files_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE csv_files_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: csv_files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE csv_files_id_seq OWNED BY csv_files.id;


--
-- Name: deadlines; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE deadlines (
    id integer NOT NULL,
    title text NOT NULL,
    soft_deadline boolean DEFAULT false,
    due_date timestamp without time zone,
    questionnaire_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: deadlines_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE deadlines_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: deadlines_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE deadlines_id_seq OWNED BY deadlines.id;


--
-- Name: delegate_text_answers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE delegate_text_answers (
    id integer NOT NULL,
    answer_id integer NOT NULL,
    user_id integer NOT NULL,
    answer_text text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: delegate_text_answers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE delegate_text_answers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: delegate_text_answers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE delegate_text_answers_id_seq OWNED BY delegate_text_answers.id;


--
-- Name: delegated_loop_item_names; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE delegated_loop_item_names (
    id integer NOT NULL,
    loop_item_name_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    delegation_section_id integer
);


--
-- Name: delegated_loop_item_names_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE delegated_loop_item_names_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: delegated_loop_item_names_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE delegated_loop_item_names_id_seq OWNED BY delegated_loop_item_names.id;


--
-- Name: delegation_sections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE delegation_sections (
    id integer NOT NULL,
    delegation_id integer NOT NULL,
    section_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    original_id integer
);


--
-- Name: delegation_sections_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE delegation_sections_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: delegation_sections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE delegation_sections_id_seq OWNED BY delegation_sections.id;


--
-- Name: delegations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE delegations (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    remarks text,
    questionnaire_id integer,
    user_delegate_id integer,
    from_submission boolean,
    original_id integer,
    can_view_all_questionnaire boolean DEFAULT false
);


--
-- Name: delegations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE delegations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: delegations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE delegations_id_seq OWNED BY delegations.id;


--
-- Name: documents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE documents (
    id integer NOT NULL,
    answer_id integer NOT NULL,
    doc_file_name text NOT NULL,
    doc_content_type character varying(255),
    doc_file_size integer,
    doc_updated_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    description text,
    original_id integer
);


--
-- Name: documents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE documents_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE documents_id_seq OWNED BY documents.id;


--
-- Name: extras; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE extras (
    id integer NOT NULL,
    name text NOT NULL,
    loop_item_type_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    field_type integer NOT NULL,
    original_id integer
);


--
-- Name: extras_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE extras_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: extras_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE extras_id_seq OWNED BY extras.id;


--
-- Name: filtering_fields; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE filtering_fields (
    id integer NOT NULL,
    name text NOT NULL,
    questionnaire_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    original_id integer
);


--
-- Name: filtering_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE filtering_fields_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: filtering_fields_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE filtering_fields_id_seq OWNED BY filtering_fields.id;


--
-- Name: item_extra_fields; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE item_extra_fields (
    id integer NOT NULL,
    item_extra_id integer NOT NULL,
    language character varying(255) DEFAULT 'en'::character varying NOT NULL,
    value text NOT NULL,
    is_default_language boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: item_extra_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE item_extra_fields_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: item_extra_fields_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE item_extra_fields_id_seq OWNED BY item_extra_fields.id;


--
-- Name: item_extras; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE item_extras (
    id integer NOT NULL,
    loop_item_name_id integer NOT NULL,
    extra_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    original_id integer
);


--
-- Name: item_extras_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE item_extras_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: item_extras_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE item_extras_id_seq OWNED BY item_extras.id;


--
-- Name: loop_item_name_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE loop_item_name_fields_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: loop_item_name_fields_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE loop_item_name_fields_id_seq OWNED BY loop_item_name_fields.id;


--
-- Name: loop_item_names_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE loop_item_names_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: loop_item_names_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE loop_item_names_id_seq OWNED BY loop_item_names.id;


--
-- Name: loop_item_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE loop_item_types (
    id integer NOT NULL,
    name text NOT NULL,
    parent_id integer,
    lft integer,
    rgt integer,
    loop_source_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    filtering_field_id integer,
    original_id integer
);


--
-- Name: loop_item_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE loop_item_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: loop_item_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE loop_item_types_id_seq OWNED BY loop_item_types.id;


--
-- Name: loop_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE loop_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: loop_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE loop_items_id_seq OWNED BY loop_items.id;


--
-- Name: loop_sources; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE loop_sources (
    id integer NOT NULL,
    name text NOT NULL,
    questionnaire_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    original_id integer
);


--
-- Name: loop_sources_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE loop_sources_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: loop_sources_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE loop_sources_id_seq OWNED BY loop_sources.id;


--
-- Name: matrix_answer_drop_option_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE matrix_answer_drop_option_fields_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: matrix_answer_drop_option_fields_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE matrix_answer_drop_option_fields_id_seq OWNED BY matrix_answer_drop_option_fields.id;


--
-- Name: matrix_answer_drop_options_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE matrix_answer_drop_options_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: matrix_answer_drop_options_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE matrix_answer_drop_options_id_seq OWNED BY matrix_answer_drop_options.id;


--
-- Name: matrix_answer_option_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE matrix_answer_option_fields_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: matrix_answer_option_fields_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE matrix_answer_option_fields_id_seq OWNED BY matrix_answer_option_fields.id;


--
-- Name: matrix_answer_options_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE matrix_answer_options_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: matrix_answer_options_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE matrix_answer_options_id_seq OWNED BY matrix_answer_options.id;


--
-- Name: matrix_answer_queries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE matrix_answer_queries_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: matrix_answer_queries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE matrix_answer_queries_id_seq OWNED BY matrix_answer_queries.id;


--
-- Name: matrix_answer_query_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE matrix_answer_query_fields_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: matrix_answer_query_fields_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE matrix_answer_query_fields_id_seq OWNED BY matrix_answer_query_fields.id;


--
-- Name: matrix_answers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE matrix_answers (
    id integer NOT NULL,
    display_reply integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    matrix_orientation integer NOT NULL,
    original_id integer
);


--
-- Name: matrix_answers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE matrix_answers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: matrix_answers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE matrix_answers_id_seq OWNED BY matrix_answers.id;


--
-- Name: multi_answer_option_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE multi_answer_option_fields_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: multi_answer_option_fields_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE multi_answer_option_fields_id_seq OWNED BY multi_answer_option_fields.id;


--
-- Name: multi_answer_options_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE multi_answer_options_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: multi_answer_options_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE multi_answer_options_id_seq OWNED BY multi_answer_options.id;


--
-- Name: multi_answers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE multi_answers (
    id integer NOT NULL,
    single boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    other_required boolean DEFAULT false NOT NULL,
    display_type integer NOT NULL,
    original_id integer
);


--
-- Name: multi_answers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE multi_answers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: multi_answers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE multi_answers_id_seq OWNED BY multi_answers.id;


--
-- Name: numeric_answers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE numeric_answers (
    id integer NOT NULL,
    max_value integer,
    min_value integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    original_id integer
);


--
-- Name: numeric_answers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE numeric_answers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: numeric_answers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE numeric_answers_id_seq OWNED BY numeric_answers.id;


--
-- Name: other_fields; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE other_fields (
    id integer NOT NULL,
    language character varying(255) NOT NULL,
    other_text text,
    multi_answer_id integer NOT NULL,
    is_default_language boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: other_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE other_fields_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: other_fields_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE other_fields_id_seq OWNED BY other_fields.id;


--
-- Name: pdf_files; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE pdf_files (
    id integer NOT NULL,
    questionnaire_id integer NOT NULL,
    user_id integer NOT NULL,
    name character varying(255),
    location character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    is_long boolean DEFAULT true
);


--
-- Name: pdf_files_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE pdf_files_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pdf_files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE pdf_files_id_seq OWNED BY pdf_files.id;


--
-- Name: persistent_errors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE persistent_errors (
    id integer NOT NULL,
    title character varying(255),
    details text,
    "timestamp" timestamp without time zone,
    user_id integer NOT NULL,
    errorable_type character varying(255),
    errorable_id integer,
    user_ip character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: persistent_errors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE persistent_errors_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: persistent_errors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE persistent_errors_id_seq OWNED BY persistent_errors.id;


--
-- Name: pt_matrix_answer_option_codes_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW pt_matrix_answer_option_codes_view AS
 SELECT questions.id AS question_id,
    questions.is_mandatory,
    ma.id AS matrix_answer_id,
    mao.id AS matrix_answer_drop_option_id,
    questions.uidentifier,
    maof.option_text,
        CASE
            WHEN ("position"((maof.option_text)::text, '='::text) > 0) THEN "substring"(squish_null((maof.option_text)::text), 1, ("position"(squish_null((maof.option_text)::text), '='::text) - 1))
            ELSE 'UNKNOWN'::text
        END AS option_code
   FROM (((questions
     JOIN matrix_answers ma ON ((questions.answer_type_id = ma.id)))
     JOIN matrix_answer_drop_options mao ON ((ma.id = mao.matrix_answer_id)))
     JOIN matrix_answer_drop_option_fields maof ON (((mao.id = maof.matrix_answer_drop_option_id) AND maof.is_default_language)));


--
-- Name: pt_questions_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW pt_questions_view AS
 WITH RECURSIVE questionnaire_parts_with_descendents AS (
         SELECT section_fields.tab_title AS root_section,
            NULL::text AS goal,
            questionnaire_parts.id,
            questionnaire_parts.questionnaire_id,
            questionnaire_parts.part_id,
            questionnaire_parts.part_type,
            questionnaire_parts.parent_id,
            NULL::integer AS parent_part_id,
            NULL::text AS parent_part_type,
            questionnaire_parts.lft
           FROM ((questionnaire_parts
             LEFT JOIN sections ON (((sections.id = questionnaire_parts.part_id) AND ((questionnaire_parts.part_type)::text = 'Section'::text))))
             LEFT JOIN section_fields ON (((section_fields.section_id = sections.id) AND section_fields.is_default_language)))
          WHERE (questionnaire_parts.parent_id IS NULL)
        UNION ALL
         SELECT h.root_section,
                CASE
                    WHEN (h.goal IS NULL) THEN "substring"(section_fields.title, 'Goal \d+'::text)
                    ELSE h.goal
                END AS goal,
            hi.id,
            h.questionnaire_id,
            hi.part_id,
            hi.part_type,
            hi.parent_id,
            h.part_id,
            h.part_type,
            hi.lft
           FROM (((questionnaire_parts hi
             JOIN questionnaire_parts_with_descendents h ON ((h.id = hi.parent_id)))
             LEFT JOIN sections ON (((sections.id = hi.part_id) AND ((hi.part_type)::text = 'Section'::text))))
             LEFT JOIN section_fields ON (((section_fields.section_id = sections.id) AND section_fields.is_default_language)))
        )
 SELECT qp.root_section,
    qp.goal,
    qp.parent_part_id AS section_id,
    questions.id,
    qp.questionnaire_id,
    questions.uidentifier,
    questions.answer_type_type,
    questions.answer_type_id,
    qp.lft
   FROM (questionnaire_parts_with_descendents qp
     JOIN questions ON (((questions.id = qp.part_id) AND ((qp.part_type)::text = 'Question'::text))));


--
-- Name: pt_matrix_answer_answers_by_user_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW pt_matrix_answer_answers_by_user_view AS
 SELECT q.id AS question_id,
    q.uidentifier,
    answers.id AS answer_id,
    ap.field_type_id AS matrix_answer_query_id,
    answers.looping_identifier,
        CASE
            WHEN (answers.id IS NOT NULL) THEN mao.option_code
            ELSE 'EMPTY'::text
        END AS option_code,
    answers.user_id
   FROM ((((pt_questions_view q
     LEFT JOIN answers ON ((answers.question_id = q.id)))
     LEFT JOIN answer_parts ap ON (((ap.answer_id = answers.id) AND ((ap.field_type_type)::text = 'MatrixAnswerQuery'::text))))
     LEFT JOIN answer_part_matrix_options apm ON ((apm.answer_part_id = ap.id)))
     LEFT JOIN pt_matrix_answer_option_codes_view mao ON (((mao.matrix_answer_drop_option_id = apm.matrix_answer_drop_option_id) AND (q.id = mao.question_id))))
  WHERE ((q.answer_type_type)::text = 'MatrixAnswer'::text);


--
-- Name: pt_multi_answer_option_codes_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW pt_multi_answer_option_codes_view AS
 SELECT questions.id AS question_id,
    questions.is_mandatory,
    mao.details_field,
    ma.id AS multi_answer_id,
    mao.id AS multi_answer_option_id,
    questions.uidentifier,
    maof.option_text,
        CASE
            WHEN ("position"(maof.option_text, '='::text) > 0) THEN "substring"(squish_null(maof.option_text), 1, ("position"(squish_null(maof.option_text), '='::text) - 1))
            ELSE 'UNKNOWN'::text
        END AS option_code
   FROM (((questions
     JOIN multi_answers ma ON ((questions.answer_type_id = ma.id)))
     JOIN multi_answer_options mao ON ((ma.id = mao.multi_answer_id)))
     JOIN multi_answer_option_fields maof ON (((mao.id = maof.multi_answer_option_id) AND maof.is_default_language)));


--
-- Name: pt_multi_answer_answers_by_user_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW pt_multi_answer_answers_by_user_view AS
 SELECT q.id AS question_id,
    q.uidentifier,
    answers.id AS answer_id,
    answers.looping_identifier,
        CASE
            WHEN (answers.id IS NOT NULL) THEN mao.option_code
            ELSE 'EMPTY'::text
        END AS option_code,
    mao.details_field,
    ap.details_text,
    answers.user_id
   FROM (((pt_questions_view q
     LEFT JOIN answers ON ((answers.question_id = q.id)))
     LEFT JOIN answer_parts ap ON (((ap.answer_id = answers.id) AND ((ap.field_type_type)::text = 'MultiAnswerOption'::text))))
     LEFT JOIN pt_multi_answer_option_codes_view mao ON (((mao.multi_answer_option_id = ap.field_type_id) AND (q.id = mao.question_id))))
  WHERE ((q.answer_type_type)::text = 'MultiAnswer'::text);


--
-- Name: question_extras; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE question_extras (
    id integer NOT NULL,
    question_id integer NOT NULL,
    extra_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: question_extras_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE question_extras_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: question_extras_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE question_extras_id_seq OWNED BY question_extras.id;


--
-- Name: question_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE question_fields_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: question_fields_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE question_fields_id_seq OWNED BY question_fields.id;


--
-- Name: question_loop_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE question_loop_types (
    id integer NOT NULL,
    question_id integer NOT NULL,
    loop_item_type_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: question_loop_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE question_loop_types_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: question_loop_types_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE question_loop_types_id_seq OWNED BY question_loop_types.id;


--
-- Name: questionnaire_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE questionnaire_fields_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: questionnaire_fields_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE questionnaire_fields_id_seq OWNED BY questionnaire_fields.id;


--
-- Name: questionnaire_parts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE questionnaire_parts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: questionnaire_parts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE questionnaire_parts_id_seq OWNED BY questionnaire_parts.id;


--
-- Name: questionnaires_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE questionnaires_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: questionnaires_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE questionnaires_id_seq OWNED BY questionnaires.id;


--
-- Name: questions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE questions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: questions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE questions_id_seq OWNED BY questions.id;


--
-- Name: range_answer_option_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE range_answer_option_fields_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: range_answer_option_fields_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE range_answer_option_fields_id_seq OWNED BY range_answer_option_fields.id;


--
-- Name: range_answer_options_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE range_answer_options_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: range_answer_options_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE range_answer_options_id_seq OWNED BY range_answer_options.id;


--
-- Name: range_answers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE range_answers (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    original_id integer
);


--
-- Name: range_answers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE range_answers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: range_answers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE range_answers_id_seq OWNED BY range_answers.id;


--
-- Name: rank_answer_option_fields; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE rank_answer_option_fields (
    id integer NOT NULL,
    rank_answer_option_id integer NOT NULL,
    language character varying(255) NOT NULL,
    option_text text,
    is_default_language boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: rank_answer_option_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE rank_answer_option_fields_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rank_answer_option_fields_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE rank_answer_option_fields_id_seq OWNED BY rank_answer_option_fields.id;


--
-- Name: rank_answer_options; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE rank_answer_options (
    id integer NOT NULL,
    rank_answer_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    original_id integer
);


--
-- Name: rank_answer_options_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE rank_answer_options_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rank_answer_options_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE rank_answer_options_id_seq OWNED BY rank_answer_options.id;


--
-- Name: rank_answers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE rank_answers (
    id integer NOT NULL,
    maximum_choices integer DEFAULT '-1'::integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    original_id integer
);


--
-- Name: rank_answers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE rank_answers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rank_answers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE rank_answers_id_seq OWNED BY rank_answers.id;


--
-- Name: reminders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE reminders (
    id integer NOT NULL,
    title text NOT NULL,
    body text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    days integer
);


--
-- Name: reminders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE reminders_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reminders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE reminders_id_seq OWNED BY reminders.id;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE roles (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    order_index integer
);


--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: roles_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE roles_id_seq OWNED BY roles.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: section_extras; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE section_extras (
    id integer NOT NULL,
    section_id integer NOT NULL,
    extra_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: section_extras_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE section_extras_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: section_extras_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE section_extras_id_seq OWNED BY section_extras.id;


--
-- Name: section_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE section_fields_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: section_fields_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE section_fields_id_seq OWNED BY section_fields.id;


--
-- Name: sections_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE sections_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sections_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE sections_id_seq OWNED BY sections.id;


--
-- Name: source_files; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE source_files (
    id integer NOT NULL,
    loop_source_id integer NOT NULL,
    source_file_name text NOT NULL,
    source_content_type character varying(255),
    source_file_size integer,
    source_updated_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    parse_status integer DEFAULT 0
);


--
-- Name: source_files_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE source_files_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: source_files_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE source_files_id_seq OWNED BY source_files.id;


--
-- Name: taggings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE taggings (
    id integer NOT NULL,
    tag_id integer NOT NULL,
    taggable_id integer,
    tagger_id integer,
    tagger_type character varying(255),
    taggable_type character varying(255),
    context character varying(255),
    created_at timestamp without time zone NOT NULL
);


--
-- Name: taggings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE taggings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: taggings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE taggings_id_seq OWNED BY taggings.id;


--
-- Name: tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE tags (
    id integer NOT NULL,
    name character varying(255) NOT NULL
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tags_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tags_id_seq OWNED BY tags.id;


--
-- Name: text_answer_fields; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE text_answer_fields (
    id integer NOT NULL,
    text_answer_id integer NOT NULL,
    rows integer DEFAULT 5 NOT NULL,
    width integer DEFAULT 600 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    original_id integer
);


--
-- Name: text_answer_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE text_answer_fields_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: text_answer_fields_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE text_answer_fields_id_seq OWNED BY text_answer_fields.id;


--
-- Name: text_answers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE text_answers (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    original_id integer
);


--
-- Name: text_answers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE text_answers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: text_answers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE text_answers_id_seq OWNED BY text_answers.id;


--
-- Name: user_delegates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE user_delegates (
    id integer NOT NULL,
    user_id integer NOT NULL,
    delegate_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    state integer DEFAULT 0
);


--
-- Name: user_delegates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_delegates_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_delegates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_delegates_id_seq OWNED BY user_delegates.id;


--
-- Name: user_filtering_fields; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE user_filtering_fields (
    id integer NOT NULL,
    user_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    filtering_field_id integer NOT NULL,
    field_value character varying(255)
);


--
-- Name: user_filtering_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_filtering_fields_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_filtering_fields_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_filtering_fields_id_seq OWNED BY user_filtering_fields.id;


--
-- Name: user_section_submission_states; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE user_section_submission_states (
    id integer NOT NULL,
    user_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    section_state integer DEFAULT 4,
    section_id integer NOT NULL,
    looping_identifier character varying(255),
    loop_item_id integer,
    dont_care boolean DEFAULT false
);


--
-- Name: user_section_submission_states_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_section_submission_states_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_section_submission_states_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_section_submission_states_id_seq OWNED BY user_section_submission_states.id;


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: alerts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY alerts ALTER COLUMN id SET DEFAULT nextval('alerts_id_seq'::regclass);


--
-- Name: answer_links id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY answer_links ALTER COLUMN id SET DEFAULT nextval('answer_links_id_seq'::regclass);


--
-- Name: answer_part_matrix_options id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY answer_part_matrix_options ALTER COLUMN id SET DEFAULT nextval('answer_part_matrix_options_id_seq'::regclass);


--
-- Name: answer_parts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY answer_parts ALTER COLUMN id SET DEFAULT nextval('answer_parts_id_seq'::regclass);


--
-- Name: answer_type_fields id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY answer_type_fields ALTER COLUMN id SET DEFAULT nextval('answer_type_fields_id_seq'::regclass);


--
-- Name: answers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY answers ALTER COLUMN id SET DEFAULT nextval('answers_id_seq'::regclass);


--
-- Name: application_profiles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY application_profiles ALTER COLUMN id SET DEFAULT nextval('application_profiles_id_seq'::regclass);


--
-- Name: assignments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY assignments ALTER COLUMN id SET DEFAULT nextval('assignments_id_seq'::regclass);


--
-- Name: authorized_submitters id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY authorized_submitters ALTER COLUMN id SET DEFAULT nextval('authorized_submitters_id_seq'::regclass);


--
-- Name: csv_files id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY csv_files ALTER COLUMN id SET DEFAULT nextval('csv_files_id_seq'::regclass);


--
-- Name: deadlines id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY deadlines ALTER COLUMN id SET DEFAULT nextval('deadlines_id_seq'::regclass);


--
-- Name: delegate_text_answers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY delegate_text_answers ALTER COLUMN id SET DEFAULT nextval('delegate_text_answers_id_seq'::regclass);


--
-- Name: delegated_loop_item_names id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY delegated_loop_item_names ALTER COLUMN id SET DEFAULT nextval('delegated_loop_item_names_id_seq'::regclass);


--
-- Name: delegation_sections id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY delegation_sections ALTER COLUMN id SET DEFAULT nextval('delegation_sections_id_seq'::regclass);


--
-- Name: delegations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY delegations ALTER COLUMN id SET DEFAULT nextval('delegations_id_seq'::regclass);


--
-- Name: documents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY documents ALTER COLUMN id SET DEFAULT nextval('documents_id_seq'::regclass);


--
-- Name: extras id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY extras ALTER COLUMN id SET DEFAULT nextval('extras_id_seq'::regclass);


--
-- Name: filtering_fields id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY filtering_fields ALTER COLUMN id SET DEFAULT nextval('filtering_fields_id_seq'::regclass);


--
-- Name: item_extra_fields id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY item_extra_fields ALTER COLUMN id SET DEFAULT nextval('item_extra_fields_id_seq'::regclass);


--
-- Name: item_extras id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY item_extras ALTER COLUMN id SET DEFAULT nextval('item_extras_id_seq'::regclass);


--
-- Name: loop_item_name_fields id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY loop_item_name_fields ALTER COLUMN id SET DEFAULT nextval('loop_item_name_fields_id_seq'::regclass);


--
-- Name: loop_item_names id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY loop_item_names ALTER COLUMN id SET DEFAULT nextval('loop_item_names_id_seq'::regclass);


--
-- Name: loop_item_types id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY loop_item_types ALTER COLUMN id SET DEFAULT nextval('loop_item_types_id_seq'::regclass);


--
-- Name: loop_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY loop_items ALTER COLUMN id SET DEFAULT nextval('loop_items_id_seq'::regclass);


--
-- Name: loop_sources id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY loop_sources ALTER COLUMN id SET DEFAULT nextval('loop_sources_id_seq'::regclass);


--
-- Name: matrix_answer_drop_option_fields id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY matrix_answer_drop_option_fields ALTER COLUMN id SET DEFAULT nextval('matrix_answer_drop_option_fields_id_seq'::regclass);


--
-- Name: matrix_answer_drop_options id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY matrix_answer_drop_options ALTER COLUMN id SET DEFAULT nextval('matrix_answer_drop_options_id_seq'::regclass);


--
-- Name: matrix_answer_option_fields id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY matrix_answer_option_fields ALTER COLUMN id SET DEFAULT nextval('matrix_answer_option_fields_id_seq'::regclass);


--
-- Name: matrix_answer_options id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY matrix_answer_options ALTER COLUMN id SET DEFAULT nextval('matrix_answer_options_id_seq'::regclass);


--
-- Name: matrix_answer_queries id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY matrix_answer_queries ALTER COLUMN id SET DEFAULT nextval('matrix_answer_queries_id_seq'::regclass);


--
-- Name: matrix_answer_query_fields id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY matrix_answer_query_fields ALTER COLUMN id SET DEFAULT nextval('matrix_answer_query_fields_id_seq'::regclass);


--
-- Name: matrix_answers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY matrix_answers ALTER COLUMN id SET DEFAULT nextval('matrix_answers_id_seq'::regclass);


--
-- Name: multi_answer_option_fields id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY multi_answer_option_fields ALTER COLUMN id SET DEFAULT nextval('multi_answer_option_fields_id_seq'::regclass);


--
-- Name: multi_answer_options id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY multi_answer_options ALTER COLUMN id SET DEFAULT nextval('multi_answer_options_id_seq'::regclass);


--
-- Name: multi_answers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY multi_answers ALTER COLUMN id SET DEFAULT nextval('multi_answers_id_seq'::regclass);


--
-- Name: numeric_answers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY numeric_answers ALTER COLUMN id SET DEFAULT nextval('numeric_answers_id_seq'::regclass);


--
-- Name: other_fields id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY other_fields ALTER COLUMN id SET DEFAULT nextval('other_fields_id_seq'::regclass);


--
-- Name: pdf_files id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY pdf_files ALTER COLUMN id SET DEFAULT nextval('pdf_files_id_seq'::regclass);


--
-- Name: persistent_errors id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY persistent_errors ALTER COLUMN id SET DEFAULT nextval('persistent_errors_id_seq'::regclass);


--
-- Name: question_extras id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY question_extras ALTER COLUMN id SET DEFAULT nextval('question_extras_id_seq'::regclass);


--
-- Name: question_fields id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY question_fields ALTER COLUMN id SET DEFAULT nextval('question_fields_id_seq'::regclass);


--
-- Name: question_loop_types id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY question_loop_types ALTER COLUMN id SET DEFAULT nextval('question_loop_types_id_seq'::regclass);


--
-- Name: questionnaire_fields id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY questionnaire_fields ALTER COLUMN id SET DEFAULT nextval('questionnaire_fields_id_seq'::regclass);


--
-- Name: questionnaire_parts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY questionnaire_parts ALTER COLUMN id SET DEFAULT nextval('questionnaire_parts_id_seq'::regclass);


--
-- Name: questionnaires id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY questionnaires ALTER COLUMN id SET DEFAULT nextval('questionnaires_id_seq'::regclass);


--
-- Name: questions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY questions ALTER COLUMN id SET DEFAULT nextval('questions_id_seq'::regclass);


--
-- Name: range_answer_option_fields id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY range_answer_option_fields ALTER COLUMN id SET DEFAULT nextval('range_answer_option_fields_id_seq'::regclass);


--
-- Name: range_answer_options id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY range_answer_options ALTER COLUMN id SET DEFAULT nextval('range_answer_options_id_seq'::regclass);


--
-- Name: range_answers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY range_answers ALTER COLUMN id SET DEFAULT nextval('range_answers_id_seq'::regclass);


--
-- Name: rank_answer_option_fields id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY rank_answer_option_fields ALTER COLUMN id SET DEFAULT nextval('rank_answer_option_fields_id_seq'::regclass);


--
-- Name: rank_answer_options id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY rank_answer_options ALTER COLUMN id SET DEFAULT nextval('rank_answer_options_id_seq'::regclass);


--
-- Name: rank_answers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY rank_answers ALTER COLUMN id SET DEFAULT nextval('rank_answers_id_seq'::regclass);


--
-- Name: reminders id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY reminders ALTER COLUMN id SET DEFAULT nextval('reminders_id_seq'::regclass);


--
-- Name: roles id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY roles ALTER COLUMN id SET DEFAULT nextval('roles_id_seq'::regclass);


--
-- Name: section_extras id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY section_extras ALTER COLUMN id SET DEFAULT nextval('section_extras_id_seq'::regclass);


--
-- Name: section_fields id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY section_fields ALTER COLUMN id SET DEFAULT nextval('section_fields_id_seq'::regclass);


--
-- Name: sections id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY sections ALTER COLUMN id SET DEFAULT nextval('sections_id_seq'::regclass);


--
-- Name: source_files id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY source_files ALTER COLUMN id SET DEFAULT nextval('source_files_id_seq'::regclass);


--
-- Name: taggings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY taggings ALTER COLUMN id SET DEFAULT nextval('taggings_id_seq'::regclass);


--
-- Name: tags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tags ALTER COLUMN id SET DEFAULT nextval('tags_id_seq'::regclass);


--
-- Name: text_answer_fields id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY text_answer_fields ALTER COLUMN id SET DEFAULT nextval('text_answer_fields_id_seq'::regclass);


--
-- Name: text_answers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY text_answers ALTER COLUMN id SET DEFAULT nextval('text_answers_id_seq'::regclass);


--
-- Name: user_delegates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_delegates ALTER COLUMN id SET DEFAULT nextval('user_delegates_id_seq'::regclass);


--
-- Name: user_filtering_fields id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_filtering_fields ALTER COLUMN id SET DEFAULT nextval('user_filtering_fields_id_seq'::regclass);


--
-- Name: user_section_submission_states id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_section_submission_states ALTER COLUMN id SET DEFAULT nextval('user_section_submission_states_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: alerts alerts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY alerts
    ADD CONSTRAINT alerts_pkey PRIMARY KEY (id);


--
-- Name: answer_links answer_links_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY answer_links
    ADD CONSTRAINT answer_links_pkey PRIMARY KEY (id);


--
-- Name: answer_part_matrix_options answer_part_matrix_options_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY answer_part_matrix_options
    ADD CONSTRAINT answer_part_matrix_options_pkey PRIMARY KEY (id);


--
-- Name: answer_parts answer_parts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY answer_parts
    ADD CONSTRAINT answer_parts_pkey PRIMARY KEY (id);


--
-- Name: answer_type_fields answer_type_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY answer_type_fields
    ADD CONSTRAINT answer_type_fields_pkey PRIMARY KEY (id);


--
-- Name: answers answers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY answers
    ADD CONSTRAINT answers_pkey PRIMARY KEY (id);


--
-- Name: application_profiles application_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY application_profiles
    ADD CONSTRAINT application_profiles_pkey PRIMARY KEY (id);


--
-- Name: assignments assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY assignments
    ADD CONSTRAINT assignments_pkey PRIMARY KEY (id);


--
-- Name: authorized_submitters authorized_submitters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY authorized_submitters
    ADD CONSTRAINT authorized_submitters_pkey PRIMARY KEY (id);


--
-- Name: csv_files csv_files_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY csv_files
    ADD CONSTRAINT csv_files_pkey PRIMARY KEY (id);


--
-- Name: deadlines deadlines_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY deadlines
    ADD CONSTRAINT deadlines_pkey PRIMARY KEY (id);


--
-- Name: delegate_text_answers delegate_text_answers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY delegate_text_answers
    ADD CONSTRAINT delegate_text_answers_pkey PRIMARY KEY (id);


--
-- Name: delegated_loop_item_names delegated_loop_item_names_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY delegated_loop_item_names
    ADD CONSTRAINT delegated_loop_item_names_pkey PRIMARY KEY (id);


--
-- Name: delegation_sections delegation_sections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY delegation_sections
    ADD CONSTRAINT delegation_sections_pkey PRIMARY KEY (id);


--
-- Name: delegations delegations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY delegations
    ADD CONSTRAINT delegations_pkey PRIMARY KEY (id);


--
-- Name: documents documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY documents
    ADD CONSTRAINT documents_pkey PRIMARY KEY (id);


--
-- Name: extras extras_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY extras
    ADD CONSTRAINT extras_pkey PRIMARY KEY (id);


--
-- Name: filtering_fields filtering_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY filtering_fields
    ADD CONSTRAINT filtering_fields_pkey PRIMARY KEY (id);


--
-- Name: item_extra_fields item_extra_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY item_extra_fields
    ADD CONSTRAINT item_extra_fields_pkey PRIMARY KEY (id);


--
-- Name: item_extras item_extras_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY item_extras
    ADD CONSTRAINT item_extras_pkey PRIMARY KEY (id);


--
-- Name: loop_item_name_fields loop_item_name_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY loop_item_name_fields
    ADD CONSTRAINT loop_item_name_fields_pkey PRIMARY KEY (id);


--
-- Name: loop_item_names loop_item_names_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY loop_item_names
    ADD CONSTRAINT loop_item_names_pkey PRIMARY KEY (id);


--
-- Name: loop_item_types loop_item_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY loop_item_types
    ADD CONSTRAINT loop_item_types_pkey PRIMARY KEY (id);


--
-- Name: loop_items loop_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY loop_items
    ADD CONSTRAINT loop_items_pkey PRIMARY KEY (id);


--
-- Name: loop_sources loop_sources_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY loop_sources
    ADD CONSTRAINT loop_sources_pkey PRIMARY KEY (id);


--
-- Name: matrix_answer_drop_option_fields matrix_answer_drop_option_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY matrix_answer_drop_option_fields
    ADD CONSTRAINT matrix_answer_drop_option_fields_pkey PRIMARY KEY (id);


--
-- Name: matrix_answer_drop_options matrix_answer_drop_options_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY matrix_answer_drop_options
    ADD CONSTRAINT matrix_answer_drop_options_pkey PRIMARY KEY (id);


--
-- Name: matrix_answer_option_fields matrix_answer_option_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY matrix_answer_option_fields
    ADD CONSTRAINT matrix_answer_option_fields_pkey PRIMARY KEY (id);


--
-- Name: matrix_answer_options matrix_answer_options_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY matrix_answer_options
    ADD CONSTRAINT matrix_answer_options_pkey PRIMARY KEY (id);


--
-- Name: matrix_answer_queries matrix_answer_queries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY matrix_answer_queries
    ADD CONSTRAINT matrix_answer_queries_pkey PRIMARY KEY (id);


--
-- Name: matrix_answer_query_fields matrix_answer_query_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY matrix_answer_query_fields
    ADD CONSTRAINT matrix_answer_query_fields_pkey PRIMARY KEY (id);


--
-- Name: matrix_answers matrix_answers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY matrix_answers
    ADD CONSTRAINT matrix_answers_pkey PRIMARY KEY (id);


--
-- Name: multi_answer_option_fields multi_answer_option_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY multi_answer_option_fields
    ADD CONSTRAINT multi_answer_option_fields_pkey PRIMARY KEY (id);


--
-- Name: multi_answer_options multi_answer_options_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY multi_answer_options
    ADD CONSTRAINT multi_answer_options_pkey PRIMARY KEY (id);


--
-- Name: multi_answers multi_answers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY multi_answers
    ADD CONSTRAINT multi_answers_pkey PRIMARY KEY (id);


--
-- Name: numeric_answers numeric_answers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY numeric_answers
    ADD CONSTRAINT numeric_answers_pkey PRIMARY KEY (id);


--
-- Name: other_fields other_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY other_fields
    ADD CONSTRAINT other_fields_pkey PRIMARY KEY (id);


--
-- Name: pdf_files pdf_files_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY pdf_files
    ADD CONSTRAINT pdf_files_pkey PRIMARY KEY (id);


--
-- Name: persistent_errors persistent_errors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY persistent_errors
    ADD CONSTRAINT persistent_errors_pkey PRIMARY KEY (id);


--
-- Name: question_extras question_extras_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY question_extras
    ADD CONSTRAINT question_extras_pkey PRIMARY KEY (id);


--
-- Name: question_fields question_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY question_fields
    ADD CONSTRAINT question_fields_pkey PRIMARY KEY (id);


--
-- Name: question_loop_types question_loop_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY question_loop_types
    ADD CONSTRAINT question_loop_types_pkey PRIMARY KEY (id);


--
-- Name: questionnaire_fields questionnaire_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY questionnaire_fields
    ADD CONSTRAINT questionnaire_fields_pkey PRIMARY KEY (id);


--
-- Name: questionnaire_parts questionnaire_parts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY questionnaire_parts
    ADD CONSTRAINT questionnaire_parts_pkey PRIMARY KEY (id);


--
-- Name: questionnaires questionnaires_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY questionnaires
    ADD CONSTRAINT questionnaires_pkey PRIMARY KEY (id);


--
-- Name: questions questions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY questions
    ADD CONSTRAINT questions_pkey PRIMARY KEY (id);


--
-- Name: range_answer_option_fields range_answer_option_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY range_answer_option_fields
    ADD CONSTRAINT range_answer_option_fields_pkey PRIMARY KEY (id);


--
-- Name: range_answer_options range_answer_options_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY range_answer_options
    ADD CONSTRAINT range_answer_options_pkey PRIMARY KEY (id);


--
-- Name: range_answers range_answers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY range_answers
    ADD CONSTRAINT range_answers_pkey PRIMARY KEY (id);


--
-- Name: rank_answer_option_fields rank_answer_option_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rank_answer_option_fields
    ADD CONSTRAINT rank_answer_option_fields_pkey PRIMARY KEY (id);


--
-- Name: rank_answer_options rank_answer_options_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rank_answer_options
    ADD CONSTRAINT rank_answer_options_pkey PRIMARY KEY (id);


--
-- Name: rank_answers rank_answers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rank_answers
    ADD CONSTRAINT rank_answers_pkey PRIMARY KEY (id);


--
-- Name: reminders reminders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY reminders
    ADD CONSTRAINT reminders_pkey PRIMARY KEY (id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: section_extras section_extras_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY section_extras
    ADD CONSTRAINT section_extras_pkey PRIMARY KEY (id);


--
-- Name: section_fields section_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY section_fields
    ADD CONSTRAINT section_fields_pkey PRIMARY KEY (id);


--
-- Name: sections sections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sections
    ADD CONSTRAINT sections_pkey PRIMARY KEY (id);


--
-- Name: source_files source_files_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY source_files
    ADD CONSTRAINT source_files_pkey PRIMARY KEY (id);


--
-- Name: taggings taggings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY taggings
    ADD CONSTRAINT taggings_pkey PRIMARY KEY (id);


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: text_answer_fields text_answer_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY text_answer_fields
    ADD CONSTRAINT text_answer_fields_pkey PRIMARY KEY (id);


--
-- Name: text_answers text_answers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY text_answers
    ADD CONSTRAINT text_answers_pkey PRIMARY KEY (id);


--
-- Name: user_delegates user_delegates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_delegates
    ADD CONSTRAINT user_delegates_pkey PRIMARY KEY (id);


--
-- Name: user_filtering_fields user_filtering_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_filtering_fields
    ADD CONSTRAINT user_filtering_fields_pkey PRIMARY KEY (id);


--
-- Name: user_section_submission_states user_section_submission_states_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_section_submission_states
    ADD CONSTRAINT user_section_submission_states_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_alerts_on_deadline_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_alerts_on_deadline_id ON alerts USING btree (deadline_id);


--
-- Name: index_alerts_on_reminder_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_alerts_on_reminder_id ON alerts USING btree (reminder_id);


--
-- Name: index_answer_links_on_answer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_answer_links_on_answer_id ON answer_links USING btree (answer_id);


--
-- Name: index_answer_part_matrix_options_on_answer_part_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_answer_part_matrix_options_on_answer_part_id ON answer_part_matrix_options USING btree (answer_part_id);


--
-- Name: index_answer_part_matrix_options_on_drop_option_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_answer_part_matrix_options_on_drop_option_id ON answer_part_matrix_options USING btree (matrix_answer_drop_option_id);


--
-- Name: index_answer_part_matrix_options_on_matrix_answer_option_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_answer_part_matrix_options_on_matrix_answer_option_id ON answer_part_matrix_options USING btree (matrix_answer_option_id);


--
-- Name: index_answer_parts_on_answer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_answer_parts_on_answer_id ON answer_parts USING btree (answer_id);


--
-- Name: index_answer_parts_on_field_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_answer_parts_on_field_type_id ON answer_parts USING btree (field_type_id);


--
-- Name: index_answers_on_last_editor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_answers_on_last_editor_id ON answers USING btree (last_editor_id);


--
-- Name: index_answers_on_loop_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_answers_on_loop_item_id ON answers USING btree (loop_item_id);


--
-- Name: index_answers_on_question_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_answers_on_question_id ON answers USING btree (question_id);


--
-- Name: index_answers_on_question_id_and_user_id_and_looping_identifier; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_answers_on_question_id_and_user_id_and_looping_identifier ON answers USING btree (question_id, user_id, looping_identifier);


--
-- Name: index_answers_on_questionnaire_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_answers_on_questionnaire_id ON answers USING btree (questionnaire_id);


--
-- Name: index_answers_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_answers_on_user_id ON answers USING btree (user_id);


--
-- Name: index_assignments_on_role_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_assignments_on_role_id ON assignments USING btree (role_id);


--
-- Name: index_assignments_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_assignments_on_user_id ON assignments USING btree (user_id);


--
-- Name: index_authorized_submitters_on_questionnaire_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_authorized_submitters_on_questionnaire_id ON authorized_submitters USING btree (questionnaire_id);


--
-- Name: index_authorized_submitters_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_authorized_submitters_on_user_id ON authorized_submitters USING btree (user_id);


--
-- Name: index_deadlines_on_questionnaire_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_deadlines_on_questionnaire_id ON deadlines USING btree (questionnaire_id);


--
-- Name: index_delegate_text_answers_on_answer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_delegate_text_answers_on_answer_id ON delegate_text_answers USING btree (answer_id);


--
-- Name: index_delegate_text_answers_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_delegate_text_answers_on_user_id ON delegate_text_answers USING btree (user_id);


--
-- Name: index_delegated_loop_item_names_on_delegation_section_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_delegated_loop_item_names_on_delegation_section_id ON delegated_loop_item_names USING btree (delegation_section_id);


--
-- Name: index_delegated_loop_item_names_on_loop_item_name_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_delegated_loop_item_names_on_loop_item_name_id ON delegated_loop_item_names USING btree (loop_item_name_id);


--
-- Name: index_delegation_sections_on_delegation_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_delegation_sections_on_delegation_id ON delegation_sections USING btree (delegation_id);


--
-- Name: index_delegation_sections_on_section_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_delegation_sections_on_section_id ON delegation_sections USING btree (section_id);


--
-- Name: index_documents_on_answer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_documents_on_answer_id ON documents USING btree (answer_id);


--
-- Name: index_extras_on_loop_item_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_extras_on_loop_item_type_id ON extras USING btree (loop_item_type_id);


--
-- Name: index_filtering_fields_on_questionnaire_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_filtering_fields_on_questionnaire_id ON filtering_fields USING btree (questionnaire_id);


--
-- Name: index_item_extra_fields_on_item_extra_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_item_extra_fields_on_item_extra_id ON item_extra_fields USING btree (item_extra_id);


--
-- Name: index_item_extras_on_extra_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_item_extras_on_extra_id ON item_extras USING btree (extra_id);


--
-- Name: index_item_extras_on_loop_item_name_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_item_extras_on_loop_item_name_id ON item_extras USING btree (loop_item_name_id);


--
-- Name: index_loop_item_name_fields_on_loop_item_name_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_loop_item_name_fields_on_loop_item_name_id ON loop_item_name_fields USING btree (loop_item_name_id);


--
-- Name: index_loop_item_names_on_loop_item_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_loop_item_names_on_loop_item_type_id ON loop_item_names USING btree (loop_item_type_id);


--
-- Name: index_loop_item_names_on_loop_source_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_loop_item_names_on_loop_source_id ON loop_item_names USING btree (loop_source_id);


--
-- Name: index_loop_item_types_on_filtering_field_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_loop_item_types_on_filtering_field_id ON loop_item_types USING btree (filtering_field_id);


--
-- Name: index_loop_item_types_on_loop_source_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_loop_item_types_on_loop_source_id ON loop_item_types USING btree (loop_source_id);


--
-- Name: index_loop_item_types_on_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_loop_item_types_on_parent_id ON loop_item_types USING btree (parent_id);


--
-- Name: index_loop_item_types_on_rgt; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_loop_item_types_on_rgt ON loop_item_types USING btree (rgt);


--
-- Name: index_loop_items_on_loop_item_name_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_loop_items_on_loop_item_name_id ON loop_items USING btree (loop_item_name_id);


--
-- Name: index_loop_items_on_loop_item_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_loop_items_on_loop_item_type_id ON loop_items USING btree (loop_item_type_id);


--
-- Name: index_loop_items_on_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_loop_items_on_parent_id ON loop_items USING btree (parent_id);


--
-- Name: index_loop_items_on_rgt; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_loop_items_on_rgt ON loop_items USING btree (rgt);


--
-- Name: index_loop_sources_on_questionnaire_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_loop_sources_on_questionnaire_id ON loop_sources USING btree (questionnaire_id);


--
-- Name: index_matrix_answer_drop_option_fields_on_drop_option_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_matrix_answer_drop_option_fields_on_drop_option_id ON matrix_answer_drop_option_fields USING btree (matrix_answer_drop_option_id);


--
-- Name: index_matrix_answer_drop_options_on_matrix_answer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_matrix_answer_drop_options_on_matrix_answer_id ON matrix_answer_drop_options USING btree (matrix_answer_id);


--
-- Name: index_matrix_answer_option_fields_on_matrix_answer_option_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_matrix_answer_option_fields_on_matrix_answer_option_id ON matrix_answer_option_fields USING btree (matrix_answer_option_id);


--
-- Name: index_matrix_answer_options_on_matrix_answer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_matrix_answer_options_on_matrix_answer_id ON matrix_answer_options USING btree (matrix_answer_id);


--
-- Name: index_matrix_answer_queries_on_matrix_answer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_matrix_answer_queries_on_matrix_answer_id ON matrix_answer_queries USING btree (matrix_answer_id);


--
-- Name: index_matrix_answer_query_fields_on_matrix_answer_query_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_matrix_answer_query_fields_on_matrix_answer_query_id ON matrix_answer_query_fields USING btree (matrix_answer_query_id);


--
-- Name: index_multi_answer_option_fields_on_language; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_multi_answer_option_fields_on_language ON multi_answer_option_fields USING btree (language);


--
-- Name: index_multi_answer_option_fields_on_multi_answer_option_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_multi_answer_option_fields_on_multi_answer_option_id ON multi_answer_option_fields USING btree (multi_answer_option_id);


--
-- Name: index_multi_answer_options_on_multi_answer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_multi_answer_options_on_multi_answer_id ON multi_answer_options USING btree (multi_answer_id);


--
-- Name: index_other_fields_on_multi_answer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_other_fields_on_multi_answer_id ON other_fields USING btree (multi_answer_id);


--
-- Name: index_pdf_files_on_questionnaire_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pdf_files_on_questionnaire_id ON pdf_files USING btree (questionnaire_id);


--
-- Name: index_pdf_files_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pdf_files_on_user_id ON pdf_files USING btree (user_id);


--
-- Name: index_persistent_errors_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_persistent_errors_on_user_id ON persistent_errors USING btree (user_id);


--
-- Name: index_question_extras_on_extra_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_question_extras_on_extra_id ON question_extras USING btree (extra_id);


--
-- Name: index_question_extras_on_question_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_question_extras_on_question_id ON question_extras USING btree (question_id);


--
-- Name: index_question_fields_on_question_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_question_fields_on_question_id ON question_fields USING btree (question_id);


--
-- Name: index_question_fields_on_question_id_and_language; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_question_fields_on_question_id_and_language ON question_fields USING btree (question_id, language);


--
-- Name: index_question_loop_types_on_loop_item_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_question_loop_types_on_loop_item_type_id ON question_loop_types USING btree (loop_item_type_id);


--
-- Name: index_question_loop_types_on_question_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_question_loop_types_on_question_id ON question_loop_types USING btree (question_id);


--
-- Name: index_questionnaire_fields_on_questionnaire_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_questionnaire_fields_on_questionnaire_id ON questionnaire_fields USING btree (questionnaire_id);


--
-- Name: index_questionnaire_parts_on_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_questionnaire_parts_on_parent_id ON questionnaire_parts USING btree (parent_id);


--
-- Name: index_questionnaire_parts_on_questionnaire_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_questionnaire_parts_on_questionnaire_id ON questionnaire_parts USING btree (questionnaire_id);


--
-- Name: index_questionnaire_parts_on_rgt; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_questionnaire_parts_on_rgt ON questionnaire_parts USING btree (rgt);


--
-- Name: index_questionnaires_on_last_editor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_questionnaires_on_last_editor_id ON questionnaires USING btree (last_editor_id);


--
-- Name: index_questionnaires_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_questionnaires_on_user_id ON questionnaires USING btree (user_id);


--
-- Name: index_questions_on_section_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_questions_on_section_id ON questions USING btree (section_id);


--
-- Name: index_range_answer_option_fields_on_range_answer_option_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_range_answer_option_fields_on_range_answer_option_id ON range_answer_option_fields USING btree (range_answer_option_id);


--
-- Name: index_range_answer_options_on_range_answer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_range_answer_options_on_range_answer_id ON range_answer_options USING btree (range_answer_id);


--
-- Name: index_rank_answer_option_fields_on_rank_answer_option_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rank_answer_option_fields_on_rank_answer_option_id ON rank_answer_option_fields USING btree (rank_answer_option_id);


--
-- Name: index_rank_answer_options_on_rank_answer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rank_answer_options_on_rank_answer_id ON rank_answer_options USING btree (rank_answer_id);


--
-- Name: index_section_extras_on_extra_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_section_extras_on_extra_id ON section_extras USING btree (extra_id);


--
-- Name: index_section_extras_on_section_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_section_extras_on_section_id ON section_extras USING btree (section_id);


--
-- Name: index_section_fields_on_section_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_section_fields_on_section_id ON section_fields USING btree (section_id);


--
-- Name: index_section_fields_on_section_id_and_language; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_section_fields_on_section_id_and_language ON section_fields USING btree (section_id, language);


--
-- Name: index_sections_on_depends_on_option_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sections_on_depends_on_option_id ON sections USING btree (depends_on_option_id);


--
-- Name: index_sections_on_depends_on_question_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sections_on_depends_on_question_id ON sections USING btree (depends_on_question_id);


--
-- Name: index_sections_on_loop_item_type_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sections_on_loop_item_type_id ON sections USING btree (loop_item_type_id);


--
-- Name: index_sections_on_loop_source_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_sections_on_loop_source_id ON sections USING btree (loop_source_id);


--
-- Name: index_source_files_on_loop_source_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_source_files_on_loop_source_id ON source_files USING btree (loop_source_id);


--
-- Name: index_taggings_on_tag_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_taggings_on_tag_id ON taggings USING btree (tag_id);


--
-- Name: index_taggings_on_taggable_id_and_taggable_type_and_context; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_taggings_on_taggable_id_and_taggable_type_and_context ON taggings USING btree (taggable_id, taggable_type, context);


--
-- Name: index_text_answer_fields_on_text_answer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_text_answer_fields_on_text_answer_id ON text_answer_fields USING btree (text_answer_id);


--
-- Name: index_user_delegates_on_delegate_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_delegates_on_delegate_id ON user_delegates USING btree (delegate_id);


--
-- Name: index_user_delegates_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_delegates_on_user_id ON user_delegates USING btree (user_id);


--
-- Name: index_user_filtering_fields_on_filtering_field_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_filtering_fields_on_filtering_field_id ON user_filtering_fields USING btree (filtering_field_id);


--
-- Name: index_user_filtering_fields_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_filtering_fields_on_user_id ON user_filtering_fields USING btree (user_id);


--
-- Name: index_user_section_submission_states_on_loop_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_section_submission_states_on_loop_item_id ON user_section_submission_states USING btree (loop_item_id);


--
-- Name: index_user_section_submission_states_on_section_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_section_submission_states_on_section_id ON user_section_submission_states USING btree (section_id);


--
-- Name: index_user_section_submission_states_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_section_submission_states_on_user_id ON user_section_submission_states USING btree (user_id);


--
-- Name: index_users_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_creator_id ON users USING btree (creator_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: api_respondents_view _RETURN; Type: RULE; Schema: public; Owner: -
--

CREATE OR REPLACE VIEW api_respondents_view AS
 SELECT authorized_submitters.id,
    users.id AS user_id,
    authorized_submitters.questionnaire_id,
    (((users.first_name)::text || ' '::text) || (users.last_name)::text) AS full_name,
        CASE
            WHEN (authorized_submitters.status = 0) THEN 'Not started'::text
            WHEN (authorized_submitters.status = 1) THEN 'Underway'::text
            WHEN (authorized_submitters.status = 2) THEN 'Submitted'::text
            WHEN (authorized_submitters.status = 3) THEN 'Halted'::text
            ELSE 'Unknown'::text
        END AS status,
    authorized_submitters.status AS status_code,
    users.language,
    users.country,
    users.region,
    array_agg(roles.name) AS roles
   FROM (((authorized_submitters
     JOIN users ON ((users.id = authorized_submitters.user_id)))
     JOIN assignments ON ((assignments.user_id = users.id)))
     JOIN roles ON ((roles.id = assignments.role_id)))
  GROUP BY authorized_submitters.id, users.id, authorized_submitters.questionnaire_id, authorized_submitters.status, authorized_submitters.status, users.language, users.country, users.region;


--
-- Name: alerts alerts_deadline_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY alerts
    ADD CONSTRAINT alerts_deadline_id_fk FOREIGN KEY (deadline_id) REFERENCES deadlines(id) ON DELETE CASCADE;


--
-- Name: alerts alerts_reminder_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY alerts
    ADD CONSTRAINT alerts_reminder_id_fk FOREIGN KEY (reminder_id) REFERENCES reminders(id) ON DELETE CASCADE;


--
-- Name: answer_links answer_links_answer_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY answer_links
    ADD CONSTRAINT answer_links_answer_id_fk FOREIGN KEY (answer_id) REFERENCES answers(id) ON DELETE CASCADE;


--
-- Name: answer_part_matrix_options answer_part_matrix_options_answer_part_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY answer_part_matrix_options
    ADD CONSTRAINT answer_part_matrix_options_answer_part_id_fk FOREIGN KEY (answer_part_id) REFERENCES answer_parts(id) ON DELETE CASCADE;


--
-- Name: answer_part_matrix_options answer_part_matrix_options_drop_option_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY answer_part_matrix_options
    ADD CONSTRAINT answer_part_matrix_options_drop_option_id_fk FOREIGN KEY (matrix_answer_drop_option_id) REFERENCES matrix_answer_drop_options(id) ON DELETE CASCADE;


--
-- Name: answer_part_matrix_options answer_part_matrix_options_option_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY answer_part_matrix_options
    ADD CONSTRAINT answer_part_matrix_options_option_id_fk FOREIGN KEY (matrix_answer_option_id) REFERENCES matrix_answer_options(id) ON DELETE CASCADE;


--
-- Name: answer_parts answer_parts_answer_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY answer_parts
    ADD CONSTRAINT answer_parts_answer_id_fk FOREIGN KEY (answer_id) REFERENCES answers(id) ON DELETE CASCADE;


--
-- Name: answer_parts answer_parts_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY answer_parts
    ADD CONSTRAINT answer_parts_original_id_fk FOREIGN KEY (original_id) REFERENCES answer_parts(id) ON DELETE SET NULL;


--
-- Name: answers answers_last_editor_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY answers
    ADD CONSTRAINT answers_last_editor_id_fk FOREIGN KEY (last_editor_id) REFERENCES users(id) ON DELETE SET NULL;


--
-- Name: answers answers_loop_item_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY answers
    ADD CONSTRAINT answers_loop_item_id_fk FOREIGN KEY (loop_item_id) REFERENCES loop_items(id) ON DELETE CASCADE;


--
-- Name: answers answers_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY answers
    ADD CONSTRAINT answers_original_id_fk FOREIGN KEY (original_id) REFERENCES answers(id);


--
-- Name: answers answers_question_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY answers
    ADD CONSTRAINT answers_question_id_fk FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE;


--
-- Name: answers answers_questionnaire_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY answers
    ADD CONSTRAINT answers_questionnaire_id_fk FOREIGN KEY (questionnaire_id) REFERENCES questionnaires(id) ON DELETE CASCADE;


--
-- Name: answers answers_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY answers
    ADD CONSTRAINT answers_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: assignments assignments_role_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY assignments
    ADD CONSTRAINT assignments_role_id_fk FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE;


--
-- Name: assignments assignments_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY assignments
    ADD CONSTRAINT assignments_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: authorized_submitters authorized_submitters_questionnaire_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY authorized_submitters
    ADD CONSTRAINT authorized_submitters_questionnaire_id_fk FOREIGN KEY (questionnaire_id) REFERENCES questionnaires(id) ON DELETE CASCADE;


--
-- Name: authorized_submitters authorized_submitters_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY authorized_submitters
    ADD CONSTRAINT authorized_submitters_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: deadlines deadlines_questionnaire_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY deadlines
    ADD CONSTRAINT deadlines_questionnaire_id_fk FOREIGN KEY (questionnaire_id) REFERENCES questionnaires(id) ON DELETE CASCADE;


--
-- Name: delegate_text_answers delegate_text_answers_answer_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY delegate_text_answers
    ADD CONSTRAINT delegate_text_answers_answer_id_fk FOREIGN KEY (answer_id) REFERENCES answers(id);


--
-- Name: delegate_text_answers delegate_text_answers_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY delegate_text_answers
    ADD CONSTRAINT delegate_text_answers_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: delegated_loop_item_names delegated_loop_item_names_delegation_section_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY delegated_loop_item_names
    ADD CONSTRAINT delegated_loop_item_names_delegation_section_id_fk FOREIGN KEY (delegation_section_id) REFERENCES delegation_sections(id) ON DELETE CASCADE;


--
-- Name: delegated_loop_item_names delegated_loop_item_names_loop_item_name_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY delegated_loop_item_names
    ADD CONSTRAINT delegated_loop_item_names_loop_item_name_id_fk FOREIGN KEY (loop_item_name_id) REFERENCES loop_item_names(id) ON DELETE CASCADE;


--
-- Name: delegation_sections delegation_sections_delegation_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY delegation_sections
    ADD CONSTRAINT delegation_sections_delegation_id_fk FOREIGN KEY (delegation_id) REFERENCES delegations(id) ON DELETE CASCADE;


--
-- Name: delegation_sections delegation_sections_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY delegation_sections
    ADD CONSTRAINT delegation_sections_original_id_fk FOREIGN KEY (original_id) REFERENCES delegation_sections(id) ON DELETE SET NULL;


--
-- Name: delegation_sections delegation_sections_section_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY delegation_sections
    ADD CONSTRAINT delegation_sections_section_id_fk FOREIGN KEY (section_id) REFERENCES sections(id) ON DELETE CASCADE;


--
-- Name: delegations delegations_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY delegations
    ADD CONSTRAINT delegations_original_id_fk FOREIGN KEY (original_id) REFERENCES delegations(id) ON DELETE SET NULL;


--
-- Name: documents documents_answer_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY documents
    ADD CONSTRAINT documents_answer_id_fk FOREIGN KEY (answer_id) REFERENCES answers(id) ON DELETE CASCADE;


--
-- Name: documents documents_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY documents
    ADD CONSTRAINT documents_original_id_fk FOREIGN KEY (original_id) REFERENCES documents(id) ON DELETE SET NULL;


--
-- Name: extras extras_loop_item_type_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY extras
    ADD CONSTRAINT extras_loop_item_type_id_fk FOREIGN KEY (loop_item_type_id) REFERENCES loop_item_types(id) ON DELETE CASCADE;


--
-- Name: extras extras_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY extras
    ADD CONSTRAINT extras_original_id_fk FOREIGN KEY (original_id) REFERENCES extras(id) ON DELETE SET NULL;


--
-- Name: filtering_fields filtering_fields_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY filtering_fields
    ADD CONSTRAINT filtering_fields_original_id_fk FOREIGN KEY (original_id) REFERENCES filtering_fields(id) ON DELETE SET NULL;


--
-- Name: filtering_fields filtering_fields_questionnaire_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY filtering_fields
    ADD CONSTRAINT filtering_fields_questionnaire_id_fk FOREIGN KEY (questionnaire_id) REFERENCES questionnaires(id) ON DELETE CASCADE;


--
-- Name: item_extra_fields item_extra_fields_item_extra_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY item_extra_fields
    ADD CONSTRAINT item_extra_fields_item_extra_id_fk FOREIGN KEY (item_extra_id) REFERENCES item_extras(id) ON DELETE CASCADE;


--
-- Name: item_extras item_extras_extra_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY item_extras
    ADD CONSTRAINT item_extras_extra_id_fk FOREIGN KEY (extra_id) REFERENCES extras(id) ON DELETE CASCADE;


--
-- Name: item_extras item_extras_loop_item_name_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY item_extras
    ADD CONSTRAINT item_extras_loop_item_name_id_fk FOREIGN KEY (loop_item_name_id) REFERENCES loop_item_names(id) ON DELETE CASCADE;


--
-- Name: item_extras item_extras_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY item_extras
    ADD CONSTRAINT item_extras_original_id_fk FOREIGN KEY (original_id) REFERENCES item_extras(id) ON DELETE SET NULL;


--
-- Name: loop_item_name_fields loop_item_name_fields_loop_item_name_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY loop_item_name_fields
    ADD CONSTRAINT loop_item_name_fields_loop_item_name_id_fk FOREIGN KEY (loop_item_name_id) REFERENCES loop_item_names(id) ON DELETE CASCADE;


--
-- Name: loop_item_names loop_item_names_loop_item_type_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY loop_item_names
    ADD CONSTRAINT loop_item_names_loop_item_type_id_fk FOREIGN KEY (loop_item_type_id) REFERENCES loop_item_types(id) ON DELETE CASCADE;


--
-- Name: loop_item_names loop_item_names_loop_source_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY loop_item_names
    ADD CONSTRAINT loop_item_names_loop_source_id_fk FOREIGN KEY (loop_source_id) REFERENCES loop_sources(id) ON DELETE CASCADE;


--
-- Name: loop_item_names loop_item_names_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY loop_item_names
    ADD CONSTRAINT loop_item_names_original_id_fk FOREIGN KEY (original_id) REFERENCES loop_item_names(id) ON DELETE SET NULL;


--
-- Name: loop_item_types loop_item_types_filtering_field_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY loop_item_types
    ADD CONSTRAINT loop_item_types_filtering_field_id_fk FOREIGN KEY (filtering_field_id) REFERENCES filtering_fields(id) ON DELETE SET NULL;


--
-- Name: loop_item_types loop_item_types_loop_source_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY loop_item_types
    ADD CONSTRAINT loop_item_types_loop_source_id_fk FOREIGN KEY (loop_source_id) REFERENCES loop_sources(id) ON DELETE CASCADE;


--
-- Name: loop_item_types loop_item_types_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY loop_item_types
    ADD CONSTRAINT loop_item_types_original_id_fk FOREIGN KEY (original_id) REFERENCES loop_item_types(id) ON DELETE SET NULL;


--
-- Name: loop_item_types loop_item_types_parent_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY loop_item_types
    ADD CONSTRAINT loop_item_types_parent_id_fk FOREIGN KEY (parent_id) REFERENCES loop_item_types(id) ON DELETE CASCADE;


--
-- Name: loop_items loop_items_loop_item_name_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY loop_items
    ADD CONSTRAINT loop_items_loop_item_name_id_fk FOREIGN KEY (loop_item_name_id) REFERENCES loop_item_names(id) ON DELETE CASCADE;


--
-- Name: loop_items loop_items_loop_item_type_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY loop_items
    ADD CONSTRAINT loop_items_loop_item_type_id_fk FOREIGN KEY (loop_item_type_id) REFERENCES loop_item_types(id) ON DELETE CASCADE;


--
-- Name: loop_items loop_items_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY loop_items
    ADD CONSTRAINT loop_items_original_id_fk FOREIGN KEY (original_id) REFERENCES loop_items(id) ON DELETE SET NULL;


--
-- Name: loop_items loop_items_parent_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY loop_items
    ADD CONSTRAINT loop_items_parent_id_fk FOREIGN KEY (parent_id) REFERENCES loop_items(id) ON DELETE CASCADE;


--
-- Name: loop_sources loop_sources_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY loop_sources
    ADD CONSTRAINT loop_sources_original_id_fk FOREIGN KEY (original_id) REFERENCES loop_sources(id) ON DELETE SET NULL;


--
-- Name: loop_sources loop_sources_questionnaire_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY loop_sources
    ADD CONSTRAINT loop_sources_questionnaire_id_fk FOREIGN KEY (questionnaire_id) REFERENCES questionnaires(id) ON DELETE CASCADE;


--
-- Name: matrix_answer_drop_option_fields matrix_answer_drop_option_fields_drop_option_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY matrix_answer_drop_option_fields
    ADD CONSTRAINT matrix_answer_drop_option_fields_drop_option_id_fk FOREIGN KEY (matrix_answer_drop_option_id) REFERENCES matrix_answer_drop_options(id) ON DELETE CASCADE;


--
-- Name: matrix_answer_drop_options matrix_answer_drop_options_matrix_answer_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY matrix_answer_drop_options
    ADD CONSTRAINT matrix_answer_drop_options_matrix_answer_id_fk FOREIGN KEY (matrix_answer_id) REFERENCES matrix_answers(id) ON DELETE CASCADE;


--
-- Name: matrix_answer_drop_options matrix_answer_drop_options_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY matrix_answer_drop_options
    ADD CONSTRAINT matrix_answer_drop_options_original_id_fk FOREIGN KEY (original_id) REFERENCES matrix_answer_drop_options(id) ON DELETE SET NULL;


--
-- Name: matrix_answer_option_fields matrix_answer_option_fields_option_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY matrix_answer_option_fields
    ADD CONSTRAINT matrix_answer_option_fields_option_id_fk FOREIGN KEY (matrix_answer_option_id) REFERENCES matrix_answer_options(id) ON DELETE CASCADE;


--
-- Name: matrix_answer_options matrix_answer_options_matrix_answer_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY matrix_answer_options
    ADD CONSTRAINT matrix_answer_options_matrix_answer_id_fk FOREIGN KEY (matrix_answer_id) REFERENCES matrix_answers(id) ON DELETE CASCADE;


--
-- Name: matrix_answer_options matrix_answer_options_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY matrix_answer_options
    ADD CONSTRAINT matrix_answer_options_original_id_fk FOREIGN KEY (original_id) REFERENCES matrix_answer_options(id) ON DELETE SET NULL;


--
-- Name: matrix_answer_queries matrix_answer_queries_matrix_answer_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY matrix_answer_queries
    ADD CONSTRAINT matrix_answer_queries_matrix_answer_id_fk FOREIGN KEY (matrix_answer_id) REFERENCES matrix_answers(id) ON DELETE CASCADE;


--
-- Name: matrix_answer_queries matrix_answer_queries_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY matrix_answer_queries
    ADD CONSTRAINT matrix_answer_queries_original_id_fk FOREIGN KEY (original_id) REFERENCES matrix_answer_queries(id) ON DELETE SET NULL;


--
-- Name: matrix_answer_query_fields matrix_answer_query_fields_query_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY matrix_answer_query_fields
    ADD CONSTRAINT matrix_answer_query_fields_query_id_fk FOREIGN KEY (matrix_answer_query_id) REFERENCES matrix_answer_queries(id) ON DELETE CASCADE;


--
-- Name: matrix_answers matrix_answers_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY matrix_answers
    ADD CONSTRAINT matrix_answers_original_id_fk FOREIGN KEY (original_id) REFERENCES matrix_answers(id) ON DELETE SET NULL;


--
-- Name: multi_answer_option_fields multi_answer_option_fields_multi_answer_option_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY multi_answer_option_fields
    ADD CONSTRAINT multi_answer_option_fields_multi_answer_option_id_fk FOREIGN KEY (multi_answer_option_id) REFERENCES multi_answer_options(id) ON DELETE CASCADE;


--
-- Name: multi_answer_options multi_answer_options_multi_answer_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY multi_answer_options
    ADD CONSTRAINT multi_answer_options_multi_answer_id_fk FOREIGN KEY (multi_answer_id) REFERENCES multi_answers(id) ON DELETE CASCADE;


--
-- Name: multi_answer_options multi_answer_options_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY multi_answer_options
    ADD CONSTRAINT multi_answer_options_original_id_fk FOREIGN KEY (original_id) REFERENCES multi_answer_options(id) ON DELETE SET NULL;


--
-- Name: multi_answers multi_answers_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY multi_answers
    ADD CONSTRAINT multi_answers_original_id_fk FOREIGN KEY (original_id) REFERENCES multi_answers(id) ON DELETE SET NULL;


--
-- Name: numeric_answers numeric_answers_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY numeric_answers
    ADD CONSTRAINT numeric_answers_original_id_fk FOREIGN KEY (original_id) REFERENCES numeric_answers(id) ON DELETE SET NULL;


--
-- Name: other_fields other_fields_multi_answer_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY other_fields
    ADD CONSTRAINT other_fields_multi_answer_id_fk FOREIGN KEY (multi_answer_id) REFERENCES multi_answers(id) ON DELETE CASCADE;


--
-- Name: pdf_files pdf_files_questionnaire_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY pdf_files
    ADD CONSTRAINT pdf_files_questionnaire_id_fk FOREIGN KEY (questionnaire_id) REFERENCES questionnaires(id) ON DELETE CASCADE;


--
-- Name: pdf_files pdf_files_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY pdf_files
    ADD CONSTRAINT pdf_files_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: persistent_errors persistent_errors_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY persistent_errors
    ADD CONSTRAINT persistent_errors_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: question_extras question_extras_extra_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY question_extras
    ADD CONSTRAINT question_extras_extra_id_fk FOREIGN KEY (extra_id) REFERENCES extras(id) ON DELETE CASCADE;


--
-- Name: question_extras question_extras_question_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY question_extras
    ADD CONSTRAINT question_extras_question_id_fk FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE;


--
-- Name: question_fields question_fields_question_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY question_fields
    ADD CONSTRAINT question_fields_question_id_fk FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE;


--
-- Name: question_loop_types question_loop_types_loop_item_type_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY question_loop_types
    ADD CONSTRAINT question_loop_types_loop_item_type_id_fk FOREIGN KEY (loop_item_type_id) REFERENCES loop_item_types(id) ON DELETE CASCADE;


--
-- Name: question_loop_types question_loop_types_question_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY question_loop_types
    ADD CONSTRAINT question_loop_types_question_id_fk FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE;


--
-- Name: questionnaire_fields questionnaire_fields_questionnaire_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY questionnaire_fields
    ADD CONSTRAINT questionnaire_fields_questionnaire_id_fk FOREIGN KEY (questionnaire_id) REFERENCES questionnaires(id) ON DELETE CASCADE;


--
-- Name: questionnaire_parts questionnaire_parts_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY questionnaire_parts
    ADD CONSTRAINT questionnaire_parts_original_id_fk FOREIGN KEY (original_id) REFERENCES questionnaire_parts(id) ON DELETE SET NULL;


--
-- Name: questionnaire_parts questionnaire_parts_parent_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY questionnaire_parts
    ADD CONSTRAINT questionnaire_parts_parent_id_fk FOREIGN KEY (parent_id) REFERENCES questionnaire_parts(id) ON DELETE CASCADE;


--
-- Name: questionnaire_parts questionnaire_parts_questionnaire_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY questionnaire_parts
    ADD CONSTRAINT questionnaire_parts_questionnaire_id_fk FOREIGN KEY (questionnaire_id) REFERENCES questionnaires(id) ON DELETE CASCADE;


--
-- Name: questionnaires questionnaires_last_editor_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY questionnaires
    ADD CONSTRAINT questionnaires_last_editor_id_fk FOREIGN KEY (last_editor_id) REFERENCES users(id) ON DELETE SET NULL;


--
-- Name: questionnaires questionnaires_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY questionnaires
    ADD CONSTRAINT questionnaires_original_id_fk FOREIGN KEY (original_id) REFERENCES questionnaires(id) ON DELETE SET NULL;


--
-- Name: questionnaires questionnaires_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY questionnaires
    ADD CONSTRAINT questionnaires_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE RESTRICT;


--
-- Name: questions questions_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY questions
    ADD CONSTRAINT questions_original_id_fk FOREIGN KEY (original_id) REFERENCES questions(id) ON DELETE SET NULL;


--
-- Name: questions questions_section_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY questions
    ADD CONSTRAINT questions_section_id_fk FOREIGN KEY (section_id) REFERENCES sections(id) ON DELETE CASCADE;


--
-- Name: range_answer_option_fields range_answer_option_fields_range_answer_option_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY range_answer_option_fields
    ADD CONSTRAINT range_answer_option_fields_range_answer_option_id_fk FOREIGN KEY (range_answer_option_id) REFERENCES range_answer_options(id) ON DELETE CASCADE;


--
-- Name: range_answer_options range_answer_options_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY range_answer_options
    ADD CONSTRAINT range_answer_options_original_id_fk FOREIGN KEY (original_id) REFERENCES range_answer_options(id) ON DELETE SET NULL;


--
-- Name: range_answer_options range_answer_options_range_answer_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY range_answer_options
    ADD CONSTRAINT range_answer_options_range_answer_id_fk FOREIGN KEY (range_answer_id) REFERENCES range_answers(id) ON DELETE CASCADE;


--
-- Name: range_answers range_answers_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY range_answers
    ADD CONSTRAINT range_answers_original_id_fk FOREIGN KEY (original_id) REFERENCES range_answers(id) ON DELETE SET NULL;


--
-- Name: rank_answer_option_fields rank_answer_option_fields_rank_answer_option_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rank_answer_option_fields
    ADD CONSTRAINT rank_answer_option_fields_rank_answer_option_id_fk FOREIGN KEY (rank_answer_option_id) REFERENCES rank_answer_options(id) ON DELETE CASCADE;


--
-- Name: rank_answer_options rank_answer_options_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rank_answer_options
    ADD CONSTRAINT rank_answer_options_original_id_fk FOREIGN KEY (original_id) REFERENCES rank_answer_options(id) ON DELETE SET NULL;


--
-- Name: rank_answer_options rank_answer_options_rank_answer_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rank_answer_options
    ADD CONSTRAINT rank_answer_options_rank_answer_id_fk FOREIGN KEY (rank_answer_id) REFERENCES rank_answers(id) ON DELETE CASCADE;


--
-- Name: rank_answers rank_answers_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rank_answers
    ADD CONSTRAINT rank_answers_original_id_fk FOREIGN KEY (original_id) REFERENCES rank_answers(id) ON DELETE SET NULL;


--
-- Name: section_extras section_extras_extra_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY section_extras
    ADD CONSTRAINT section_extras_extra_id_fk FOREIGN KEY (extra_id) REFERENCES extras(id) ON DELETE CASCADE;


--
-- Name: section_extras section_extras_section_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY section_extras
    ADD CONSTRAINT section_extras_section_id_fk FOREIGN KEY (section_id) REFERENCES sections(id) ON DELETE CASCADE;


--
-- Name: section_fields section_fields_section_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY section_fields
    ADD CONSTRAINT section_fields_section_id_fk FOREIGN KEY (section_id) REFERENCES sections(id) ON DELETE CASCADE;


--
-- Name: sections sections_depends_on_option_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sections
    ADD CONSTRAINT sections_depends_on_option_id_fk FOREIGN KEY (depends_on_option_id) REFERENCES multi_answer_options(id) ON DELETE SET NULL;


--
-- Name: sections sections_depends_on_question_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sections
    ADD CONSTRAINT sections_depends_on_question_id_fk FOREIGN KEY (depends_on_question_id) REFERENCES questions(id) ON DELETE SET NULL;


--
-- Name: sections sections_loop_item_type_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sections
    ADD CONSTRAINT sections_loop_item_type_id_fk FOREIGN KEY (loop_item_type_id) REFERENCES loop_item_types(id) ON DELETE SET NULL;


--
-- Name: sections sections_loop_source_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sections
    ADD CONSTRAINT sections_loop_source_id_fk FOREIGN KEY (loop_source_id) REFERENCES loop_sources(id) ON DELETE SET NULL;


--
-- Name: sections sections_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sections
    ADD CONSTRAINT sections_original_id_fk FOREIGN KEY (original_id) REFERENCES sections(id) ON DELETE SET NULL;


--
-- Name: source_files source_files_loop_source_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY source_files
    ADD CONSTRAINT source_files_loop_source_id_fk FOREIGN KEY (loop_source_id) REFERENCES loop_sources(id) ON DELETE CASCADE;


--
-- Name: taggings taggings_tag_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY taggings
    ADD CONSTRAINT taggings_tag_id_fk FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE;


--
-- Name: text_answer_fields text_answer_fields_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY text_answer_fields
    ADD CONSTRAINT text_answer_fields_original_id_fk FOREIGN KEY (original_id) REFERENCES text_answer_fields(id) ON DELETE SET NULL;


--
-- Name: text_answer_fields text_answer_fields_text_answer_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY text_answer_fields
    ADD CONSTRAINT text_answer_fields_text_answer_id_fk FOREIGN KEY (text_answer_id) REFERENCES text_answers(id) ON DELETE CASCADE;


--
-- Name: text_answers text_answers_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY text_answers
    ADD CONSTRAINT text_answers_original_id_fk FOREIGN KEY (original_id) REFERENCES text_answers(id) ON DELETE SET NULL;


--
-- Name: user_delegates user_delegates_delegate_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_delegates
    ADD CONSTRAINT user_delegates_delegate_id_fk FOREIGN KEY (delegate_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: user_delegates user_delegates_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_delegates
    ADD CONSTRAINT user_delegates_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: user_filtering_fields user_filtering_fields_filtering_field_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_filtering_fields
    ADD CONSTRAINT user_filtering_fields_filtering_field_id_fk FOREIGN KEY (filtering_field_id) REFERENCES filtering_fields(id) ON DELETE CASCADE;


--
-- Name: user_filtering_fields user_filtering_fields_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_filtering_fields
    ADD CONSTRAINT user_filtering_fields_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: user_section_submission_states user_section_submission_states_loop_item_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_section_submission_states
    ADD CONSTRAINT user_section_submission_states_loop_item_id_fk FOREIGN KEY (loop_item_id) REFERENCES loop_items(id) ON DELETE CASCADE;


--
-- Name: user_section_submission_states user_section_submission_states_section_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_section_submission_states
    ADD CONSTRAINT user_section_submission_states_section_id_fk FOREIGN KEY (section_id) REFERENCES sections(id) ON DELETE CASCADE;


--
-- Name: user_section_submission_states user_section_submission_states_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_section_submission_states
    ADD CONSTRAINT user_section_submission_states_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO schema_migrations (version) VALUES ('20120116135431');

INSERT INTO schema_migrations (version) VALUES ('20120116135432');

INSERT INTO schema_migrations (version) VALUES ('20130730164507');

INSERT INTO schema_migrations (version) VALUES ('20130905092258');

INSERT INTO schema_migrations (version) VALUES ('20132906113219');

INSERT INTO schema_migrations (version) VALUES ('20140401135554');

INSERT INTO schema_migrations (version) VALUES ('20140602161511');

INSERT INTO schema_migrations (version) VALUES ('20141021124526');

INSERT INTO schema_migrations (version) VALUES ('20141021125339');

INSERT INTO schema_migrations (version) VALUES ('20141021161656');

INSERT INTO schema_migrations (version) VALUES ('20141021162536');

INSERT INTO schema_migrations (version) VALUES ('20141021164041');

INSERT INTO schema_migrations (version) VALUES ('20141021164350');

INSERT INTO schema_migrations (version) VALUES ('20141022094105');

INSERT INTO schema_migrations (version) VALUES ('20141023225134');

INSERT INTO schema_migrations (version) VALUES ('20141027210804');

INSERT INTO schema_migrations (version) VALUES ('20141028092743');

INSERT INTO schema_migrations (version) VALUES ('20141029100608');

INSERT INTO schema_migrations (version) VALUES ('20141029111800');

INSERT INTO schema_migrations (version) VALUES ('20141029134325');

INSERT INTO schema_migrations (version) VALUES ('20141029150749');

INSERT INTO schema_migrations (version) VALUES ('20141031141553');

INSERT INTO schema_migrations (version) VALUES ('20141103162636');

INSERT INTO schema_migrations (version) VALUES ('20141106140858');

INSERT INTO schema_migrations (version) VALUES ('20150211132559');

INSERT INTO schema_migrations (version) VALUES ('20150211135928');

INSERT INTO schema_migrations (version) VALUES ('20150213101851');

INSERT INTO schema_migrations (version) VALUES ('20150213165449');

INSERT INTO schema_migrations (version) VALUES ('20150217102145');

INSERT INTO schema_migrations (version) VALUES ('20150217105405');

INSERT INTO schema_migrations (version) VALUES ('20150217120022');

INSERT INTO schema_migrations (version) VALUES ('20150415115337');

INSERT INTO schema_migrations (version) VALUES ('20150420123353');

INSERT INTO schema_migrations (version) VALUES ('20150421125519');

INSERT INTO schema_migrations (version) VALUES ('20150428213052');

INSERT INTO schema_migrations (version) VALUES ('20150428215312');

INSERT INTO schema_migrations (version) VALUES ('20150428221632');

INSERT INTO schema_migrations (version) VALUES ('20150428222130');

INSERT INTO schema_migrations (version) VALUES ('20150428223139');

INSERT INTO schema_migrations (version) VALUES ('20150428223357');

INSERT INTO schema_migrations (version) VALUES ('20150428224604');

INSERT INTO schema_migrations (version) VALUES ('20150430123243');

INSERT INTO schema_migrations (version) VALUES ('20150430124107');

INSERT INTO schema_migrations (version) VALUES ('20150430124448');

INSERT INTO schema_migrations (version) VALUES ('20150430203801');

INSERT INTO schema_migrations (version) VALUES ('20150430211200');

INSERT INTO schema_migrations (version) VALUES ('20150430211732');

INSERT INTO schema_migrations (version) VALUES ('20150430212929');

INSERT INTO schema_migrations (version) VALUES ('20150501101439');

INSERT INTO schema_migrations (version) VALUES ('20150501102120');

INSERT INTO schema_migrations (version) VALUES ('20150501102443');

INSERT INTO schema_migrations (version) VALUES ('20150501124910');

INSERT INTO schema_migrations (version) VALUES ('20150501125642');

INSERT INTO schema_migrations (version) VALUES ('20150501131542');

INSERT INTO schema_migrations (version) VALUES ('20150501132140');

INSERT INTO schema_migrations (version) VALUES ('20150501135419');

INSERT INTO schema_migrations (version) VALUES ('20150501141558');

INSERT INTO schema_migrations (version) VALUES ('20150505075812');

INSERT INTO schema_migrations (version) VALUES ('20150505081824');

INSERT INTO schema_migrations (version) VALUES ('20150505083433');

INSERT INTO schema_migrations (version) VALUES ('20150505091704');

INSERT INTO schema_migrations (version) VALUES ('20150505093251');

INSERT INTO schema_migrations (version) VALUES ('20150505094630');

INSERT INTO schema_migrations (version) VALUES ('20150505103111');

INSERT INTO schema_migrations (version) VALUES ('20150505115613');

INSERT INTO schema_migrations (version) VALUES ('20150505121129');

INSERT INTO schema_migrations (version) VALUES ('20150505125013');

INSERT INTO schema_migrations (version) VALUES ('20150505131137');

INSERT INTO schema_migrations (version) VALUES ('20150506121547');

INSERT INTO schema_migrations (version) VALUES ('20150506131025');

INSERT INTO schema_migrations (version) VALUES ('20150506133407');

INSERT INTO schema_migrations (version) VALUES ('20150507124544');

INSERT INTO schema_migrations (version) VALUES ('20150507130909');

INSERT INTO schema_migrations (version) VALUES ('20150507202355');

INSERT INTO schema_migrations (version) VALUES ('20150507203709');

INSERT INTO schema_migrations (version) VALUES ('20150507213124');

INSERT INTO schema_migrations (version) VALUES ('20150507215641');

INSERT INTO schema_migrations (version) VALUES ('20150507221200');

INSERT INTO schema_migrations (version) VALUES ('20150508092210');

INSERT INTO schema_migrations (version) VALUES ('20150508103812');

INSERT INTO schema_migrations (version) VALUES ('20150508104847');

INSERT INTO schema_migrations (version) VALUES ('20150508122915');

INSERT INTO schema_migrations (version) VALUES ('20150508123653');

INSERT INTO schema_migrations (version) VALUES ('20150511132422');

INSERT INTO schema_migrations (version) VALUES ('20150511133726');

INSERT INTO schema_migrations (version) VALUES ('20150511134412');

INSERT INTO schema_migrations (version) VALUES ('20150511135501');

INSERT INTO schema_migrations (version) VALUES ('20150511140436');

INSERT INTO schema_migrations (version) VALUES ('20150511141412');

INSERT INTO schema_migrations (version) VALUES ('20150511143707');

INSERT INTO schema_migrations (version) VALUES ('20150511145501');

INSERT INTO schema_migrations (version) VALUES ('20150511151851');

INSERT INTO schema_migrations (version) VALUES ('20150511152424');

INSERT INTO schema_migrations (version) VALUES ('20150511153131');

INSERT INTO schema_migrations (version) VALUES ('20150511161131');

INSERT INTO schema_migrations (version) VALUES ('20150511162509');

INSERT INTO schema_migrations (version) VALUES ('20150511162930');

INSERT INTO schema_migrations (version) VALUES ('20150511163259');

INSERT INTO schema_migrations (version) VALUES ('20150521082738');

INSERT INTO schema_migrations (version) VALUES ('20150612151355');

INSERT INTO schema_migrations (version) VALUES ('20150928095537');

INSERT INTO schema_migrations (version) VALUES ('20151022095507');

INSERT INTO schema_migrations (version) VALUES ('20151022102946');

INSERT INTO schema_migrations (version) VALUES ('20151029095232');

INSERT INTO schema_migrations (version) VALUES ('20151030150608');

INSERT INTO schema_migrations (version) VALUES ('20151030151237');

INSERT INTO schema_migrations (version) VALUES ('20151109160327');

INSERT INTO schema_migrations (version) VALUES ('20151110093219');

INSERT INTO schema_migrations (version) VALUES ('20151111121003');

INSERT INTO schema_migrations (version) VALUES ('20151111125036');

INSERT INTO schema_migrations (version) VALUES ('20151210140142');

INSERT INTO schema_migrations (version) VALUES ('20160118154138');

INSERT INTO schema_migrations (version) VALUES ('20160202174508');

INSERT INTO schema_migrations (version) VALUES ('20160203162148');

INSERT INTO schema_migrations (version) VALUES ('20160729110539');

INSERT INTO schema_migrations (version) VALUES ('20160824085830');

INSERT INTO schema_migrations (version) VALUES ('20160915162629');

INSERT INTO schema_migrations (version) VALUES ('20160928090747');

INSERT INTO schema_migrations (version) VALUES ('20160928155053');

INSERT INTO schema_migrations (version) VALUES ('20161115121351');

INSERT INTO schema_migrations (version) VALUES ('20161121125541');

INSERT INTO schema_migrations (version) VALUES ('20170110114407');

INSERT INTO schema_migrations (version) VALUES ('20170124102315');

INSERT INTO schema_migrations (version) VALUES ('20170124103234');

INSERT INTO schema_migrations (version) VALUES ('20170124105651');

INSERT INTO schema_migrations (version) VALUES ('20170124110749');

INSERT INTO schema_migrations (version) VALUES ('20170125094150');

INSERT INTO schema_migrations (version) VALUES ('20170125100314');

INSERT INTO schema_migrations (version) VALUES ('20170125123654');

INSERT INTO schema_migrations (version) VALUES ('20170125124502');

INSERT INTO schema_migrations (version) VALUES ('20170127094936');

INSERT INTO schema_migrations (version) VALUES ('20170911133442');

INSERT INTO schema_migrations (version) VALUES ('20170926094053');

INSERT INTO schema_migrations (version) VALUES ('20180226110843');

INSERT INTO schema_migrations (version) VALUES ('20190506122830');

INSERT INTO schema_migrations (version) VALUES ('20190506154821');

INSERT INTO schema_migrations (version) VALUES ('20190510094856');

INSERT INTO schema_migrations (version) VALUES ('20190510150637');

INSERT INTO schema_migrations (version) VALUES ('20190513103623');

INSERT INTO schema_migrations (version) VALUES ('20190613083927');