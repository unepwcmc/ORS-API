--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

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


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: alerts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: answer_links; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE answer_links (
    id integer NOT NULL,
    url text,
    description text,
    title character varying(255),
    answer_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: answer_links_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE answer_links_id_seq
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
-- Name: answer_part_matrix_options; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE answer_part_matrix_options (
    id integer NOT NULL,
    answer_part_id integer,
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
-- Name: answer_parts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE answer_parts (
    id integer NOT NULL,
    answer_text text,
    answer_id integer,
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
-- Name: answer_type_fields; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE answer_type_fields (
    id integer NOT NULL,
    language character varying(255),
    help_text text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    is_default_language boolean DEFAULT false,
    answer_type_type character varying(255),
    answer_type_id integer
);


--
-- Name: answer_type_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE answer_type_fields_id_seq
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
-- Name: answers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE answers (
    id integer NOT NULL,
    user_id integer,
    questionnaire_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    other_text text,
    question_id integer,
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
-- Name: multi_answer_option_fields; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE multi_answer_option_fields (
    id integer NOT NULL,
    language character varying(255),
    option_text text,
    multi_answer_option_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    is_default_language boolean DEFAULT false
);


--
-- Name: multi_answer_options; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE multi_answer_options (
    id integer NOT NULL,
    multi_answer_id integer,
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
-- Name: range_answer_option_fields; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE range_answer_option_fields (
    id integer NOT NULL,
    range_answer_option_id integer,
    option_text character varying(255),
    language character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    is_default_language boolean
);


--
-- Name: range_answer_options; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE range_answer_options (
    id integer NOT NULL,
    range_answer_id integer,
    sort_index integer,
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
-- Name: users; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
    perishable_token character varying(255) NOT NULL,
    single_access_token character varying(255) NOT NULL,
    first_name character varying(255),
    last_name character varying(255),
    creator_id integer DEFAULT 0,
    language character varying(255) DEFAULT 'en'::character varying,
    category character varying(255)
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
    ap.details_text,
    ap.answer_text_in_english
   FROM ((((answers
     JOIN answer_parts ap ON ((ap.answer_id = answers.id)))
     JOIN users ON ((users.id = answers.user_id)))
     LEFT JOIN api_multi_answer_options_view mao ON (((mao.id = ap.field_type_id) AND ((ap.field_type_type)::text = 'MultiAnswerOption'::text))))
     LEFT JOIN api_range_answer_options_view rao ON (((rao.id = ap.field_type_id) AND ((ap.field_type_type)::text = 'RangeAnswerOption'::text))));


--
-- Name: questionnaire_fields; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE questionnaire_fields (
    id integer NOT NULL,
    language character varying(255),
    title text,
    questionnaire_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    introductory_remarks text,
    is_default_language boolean DEFAULT false,
    email_subject character varying(255) DEFAULT '---
:default: Online Reporting System
'::character varying,
    email text,
    email_footer character varying(255),
    submit_info_tip text
);


--
-- Name: questionnaires; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE questionnaires (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    last_edited timestamp without time zone,
    user_id integer,
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
    original_id integer
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
-- Name: section_fields; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE section_fields (
    id integer NOT NULL,
    title text,
    language character varying(255),
    description text,
    section_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    is_default_language boolean DEFAULT false,
    tab_title text
);


--
-- Name: sections; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sections (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    last_edited timestamp without time zone,
    section_type integer,
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
-- Name: questionnaire_parts; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: loop_item_name_fields; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE loop_item_name_fields (
    id integer NOT NULL,
    language character varying(255),
    item_name character varying(255),
    is_default_language boolean,
    loop_item_name_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: loop_item_names; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE loop_item_names (
    id integer NOT NULL,
    loop_source_id integer,
    loop_item_type_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    original_id integer
);


--
-- Name: loop_items; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE loop_items (
    id integer NOT NULL,
    parent_id integer,
    lft integer,
    rgt integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    loop_item_type_id integer,
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
            ARRAY[(linf.item_name)::text] AS "array",
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
            (li_tree_1.lin_context || ARRAY[(linf.item_name)::text]),
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
-- Name: questions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE questions (
    id integer NOT NULL,
    uidentifier character varying(255),
    type integer,
    last_edited timestamp without time zone,
    number integer,
    section_id integer,
    answer_type_id integer,
    answer_type_type character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    is_mandatory boolean DEFAULT false,
    ordering integer,
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
-- Name: question_fields; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE question_fields (
    id integer NOT NULL,
    language character varying(255),
    title text,
    short_title character varying(255),
    description text,
    question_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    is_default_language boolean DEFAULT false
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
  WHERE (((questions.answer_type_type)::text = ANY (ARRAY[('MultiAnswer'::character varying)::text, ('RangeAnswer'::character varying)::text, ('NumericAnswer'::character varying)::text])) AND (squish_null(question_fields.title) IS NOT NULL));


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
    COALESCE(mao_options.options, (rao_options.options)::text[]) AS options
   FROM (((api_questions_view q
     JOIN api_sections_tree_view s ON (((q.section_id = s.id) AND ((q.language = s.language) OR (s.is_default_language AND (NOT (s.languages @> ARRAY[q.language])))))))
     LEFT JOIN mao_options ON ((mao_options.multi_answer_id = q.answer_type_id)))
     LEFT JOIN rao_options ON ((rao_options.range_answer_id = q.answer_type_id)));


--
-- Name: authorized_submitters; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE authorized_submitters (
    id integer NOT NULL,
    user_id integer,
    questionnaire_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    status integer DEFAULT 0,
    language character varying(255) DEFAULT 'en'::character varying,
    total_questions integer DEFAULT 0,
    answered_questions integer DEFAULT 0,
    requested_unsubmission boolean DEFAULT false
);


--
-- Name: api_respondents_view; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW api_respondents_view AS
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
    authorized_submitters.status AS status_code
   FROM (authorized_submitters
     JOIN users ON ((users.id = authorized_submitters.user_id)));


--
-- Name: application_profiles; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE application_profiles (
    id integer NOT NULL,
    title character varying(255) DEFAULT ''::character varying,
    short_title character varying(255) DEFAULT ''::character varying,
    logo_url text DEFAULT ''::text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    logo_file_name character varying(255),
    logo_content_type character varying(255),
    logo_file_size integer,
    logo_updated_at timestamp without time zone
);


--
-- Name: application_profiles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE application_profiles_id_seq
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
-- Name: assignments; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: authorized_submitters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE authorized_submitters_id_seq
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
-- Name: csv_files; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: deadlines; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE deadlines (
    id integer NOT NULL,
    title character varying(255),
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
-- Name: delegate_text_answers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE delegate_text_answers (
    id integer NOT NULL,
    answer_id integer,
    user_id integer,
    answer_text text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: delegate_text_answers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE delegate_text_answers_id_seq
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
-- Name: delegated_loop_item_names; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE delegated_loop_item_names (
    id integer NOT NULL,
    loop_item_name_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    delegation_section_id integer
);


--
-- Name: delegated_loop_item_names_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE delegated_loop_item_names_id_seq
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
-- Name: delegation_sections; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE delegation_sections (
    id integer NOT NULL,
    delegation_id integer,
    section_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    original_id integer
);


--
-- Name: delegation_sections_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE delegation_sections_id_seq
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
-- Name: delegations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: documents; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE documents (
    id integer NOT NULL,
    answer_id integer,
    doc_file_name character varying(255),
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
-- Name: extras; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE extras (
    id integer NOT NULL,
    name character varying(255),
    loop_item_type_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    field_type integer,
    original_id integer
);


--
-- Name: extras_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE extras_id_seq
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
-- Name: filtering_fields; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE filtering_fields (
    id integer NOT NULL,
    name character varying(255),
    questionnaire_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    original_id integer
);


--
-- Name: filtering_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE filtering_fields_id_seq
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
-- Name: item_extra_fields; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE item_extra_fields (
    id integer NOT NULL,
    item_extra_id integer,
    language character varying(255) DEFAULT 'en'::character varying,
    value character varying(255),
    is_default_language boolean DEFAULT false,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: item_extra_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE item_extra_fields_id_seq
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
-- Name: item_extras; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE item_extras (
    id integer NOT NULL,
    loop_item_name_id integer,
    extra_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    original_id integer
);


--
-- Name: item_extras_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE item_extras_id_seq
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
-- Name: loop_item_types; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE loop_item_types (
    id integer NOT NULL,
    name character varying(255),
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
-- Name: loop_sources; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE loop_sources (
    id integer NOT NULL,
    name character varying(255),
    questionnaire_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    original_id integer
);


--
-- Name: loop_sources_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE loop_sources_id_seq
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
-- Name: matrix_answer_drop_option_fields; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE matrix_answer_drop_option_fields (
    id integer NOT NULL,
    matrix_answer_drop_option_id integer,
    language character varying(255),
    is_default_language boolean,
    option_text character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: matrix_answer_drop_option_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE matrix_answer_drop_option_fields_id_seq
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
-- Name: matrix_answer_drop_options; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE matrix_answer_drop_options (
    id integer NOT NULL,
    matrix_answer_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    original_id integer
);


--
-- Name: matrix_answer_drop_options_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE matrix_answer_drop_options_id_seq
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
-- Name: matrix_answer_option_fields; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE matrix_answer_option_fields (
    id integer NOT NULL,
    matrix_answer_option_id integer,
    language character varying(255),
    title text,
    is_default_language boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: matrix_answer_option_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE matrix_answer_option_fields_id_seq
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
-- Name: matrix_answer_options; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE matrix_answer_options (
    id integer NOT NULL,
    matrix_answer_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    original_id integer
);


--
-- Name: matrix_answer_options_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE matrix_answer_options_id_seq
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
-- Name: matrix_answer_queries; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE matrix_answer_queries (
    id integer NOT NULL,
    matrix_answer_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    original_id integer
);


--
-- Name: matrix_answer_queries_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE matrix_answer_queries_id_seq
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
-- Name: matrix_answer_query_fields; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE matrix_answer_query_fields (
    id integer NOT NULL,
    matrix_answer_query_id integer,
    language character varying(255),
    title text,
    is_default_language boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: matrix_answer_query_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE matrix_answer_query_fields_id_seq
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
-- Name: matrix_answers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE matrix_answers (
    id integer NOT NULL,
    display_reply integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    matrix_orientation integer,
    original_id integer
);


--
-- Name: matrix_answers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE matrix_answers_id_seq
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
-- Name: multi_answers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE multi_answers (
    id integer NOT NULL,
    single boolean DEFAULT true,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    other_required boolean DEFAULT false,
    display_type integer,
    original_id integer
);


--
-- Name: multi_answers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE multi_answers_id_seq
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
-- Name: numeric_answers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: other_fields; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE other_fields (
    id integer NOT NULL,
    language character varying(255),
    other_text text,
    multi_answer_id integer,
    is_default_language boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: other_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE other_fields_id_seq
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
-- Name: pdf_files; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE pdf_files (
    id integer NOT NULL,
    questionnaire_id integer,
    user_id integer,
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
-- Name: persistent_errors; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE persistent_errors (
    id integer NOT NULL,
    title character varying(255),
    details text,
    "timestamp" timestamp without time zone,
    user_id integer,
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
-- Name: question_extras; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE question_extras (
    id integer NOT NULL,
    question_id integer,
    extra_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: question_extras_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE question_extras_id_seq
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
-- Name: question_loop_types; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE question_loop_types (
    id integer NOT NULL,
    question_id integer,
    loop_item_type_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: question_loop_types_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE question_loop_types_id_seq
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
-- Name: range_answers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: rank_answer_option_fields; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE rank_answer_option_fields (
    id integer NOT NULL,
    rank_answer_option_id integer,
    language character varying(255),
    option_text text,
    is_default_language boolean,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: rank_answer_option_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE rank_answer_option_fields_id_seq
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
-- Name: rank_answer_options; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE rank_answer_options (
    id integer NOT NULL,
    rank_answer_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    original_id integer
);


--
-- Name: rank_answer_options_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE rank_answer_options_id_seq
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
-- Name: rank_answers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE rank_answers (
    id integer NOT NULL,
    maximum_choices integer DEFAULT (-1),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    original_id integer
);


--
-- Name: rank_answers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE rank_answers_id_seq
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
-- Name: reminders; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE reminders (
    id integer NOT NULL,
    title character varying(255),
    body text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    days integer
);


--
-- Name: reminders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE reminders_id_seq
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
-- Name: roles; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE roles (
    id integer NOT NULL,
    name character varying(255),
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE roles_id_seq
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
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: section_extras; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE section_extras (
    id integer NOT NULL,
    section_id integer,
    extra_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: section_extras_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE section_extras_id_seq
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
-- Name: source_files; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE source_files (
    id integer NOT NULL,
    loop_source_id integer,
    source_file_name character varying(255),
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
-- Name: taggings; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE taggings (
    id integer NOT NULL,
    tag_id integer,
    taggable_id integer,
    tagger_id integer,
    tagger_type character varying(255),
    taggable_type character varying(255),
    context character varying(255),
    created_at timestamp without time zone
);


--
-- Name: taggings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE taggings_id_seq
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
-- Name: tags; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE tags (
    id integer NOT NULL,
    name character varying(255)
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tags_id_seq
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
-- Name: text_answer_fields; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE text_answer_fields (
    id integer NOT NULL,
    text_answer_id integer,
    rows integer,
    width integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    original_id integer
);


--
-- Name: text_answer_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE text_answer_fields_id_seq
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
-- Name: text_answers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: user_delegates; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE user_delegates (
    id integer NOT NULL,
    user_id integer,
    delegate_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    state integer DEFAULT 0
);


--
-- Name: user_delegates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_delegates_id_seq
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
-- Name: user_filtering_fields; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE user_filtering_fields (
    id integer NOT NULL,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    filtering_field_id integer,
    field_value character varying(255)
);


--
-- Name: user_filtering_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_filtering_fields_id_seq
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
-- Name: user_section_submission_states; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE user_section_submission_states (
    id integer NOT NULL,
    user_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    section_state integer DEFAULT 4,
    section_id integer,
    looping_identifier character varying(255),
    loop_item_id integer,
    dont_care boolean DEFAULT false
);


--
-- Name: user_section_submission_states_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_section_submission_states_id_seq
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
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY alerts ALTER COLUMN id SET DEFAULT nextval('alerts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY answer_links ALTER COLUMN id SET DEFAULT nextval('answer_links_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY answer_part_matrix_options ALTER COLUMN id SET DEFAULT nextval('answer_part_matrix_options_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY answer_parts ALTER COLUMN id SET DEFAULT nextval('answer_parts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY answer_type_fields ALTER COLUMN id SET DEFAULT nextval('answer_type_fields_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY answers ALTER COLUMN id SET DEFAULT nextval('answers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY application_profiles ALTER COLUMN id SET DEFAULT nextval('application_profiles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY assignments ALTER COLUMN id SET DEFAULT nextval('assignments_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY authorized_submitters ALTER COLUMN id SET DEFAULT nextval('authorized_submitters_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY csv_files ALTER COLUMN id SET DEFAULT nextval('csv_files_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY deadlines ALTER COLUMN id SET DEFAULT nextval('deadlines_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY delegate_text_answers ALTER COLUMN id SET DEFAULT nextval('delegate_text_answers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY delegated_loop_item_names ALTER COLUMN id SET DEFAULT nextval('delegated_loop_item_names_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY delegation_sections ALTER COLUMN id SET DEFAULT nextval('delegation_sections_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY delegations ALTER COLUMN id SET DEFAULT nextval('delegations_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY documents ALTER COLUMN id SET DEFAULT nextval('documents_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY extras ALTER COLUMN id SET DEFAULT nextval('extras_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY filtering_fields ALTER COLUMN id SET DEFAULT nextval('filtering_fields_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY item_extra_fields ALTER COLUMN id SET DEFAULT nextval('item_extra_fields_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY item_extras ALTER COLUMN id SET DEFAULT nextval('item_extras_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY loop_item_name_fields ALTER COLUMN id SET DEFAULT nextval('loop_item_name_fields_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY loop_item_names ALTER COLUMN id SET DEFAULT nextval('loop_item_names_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY loop_item_types ALTER COLUMN id SET DEFAULT nextval('loop_item_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY loop_items ALTER COLUMN id SET DEFAULT nextval('loop_items_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY loop_sources ALTER COLUMN id SET DEFAULT nextval('loop_sources_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY matrix_answer_drop_option_fields ALTER COLUMN id SET DEFAULT nextval('matrix_answer_drop_option_fields_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY matrix_answer_drop_options ALTER COLUMN id SET DEFAULT nextval('matrix_answer_drop_options_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY matrix_answer_option_fields ALTER COLUMN id SET DEFAULT nextval('matrix_answer_option_fields_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY matrix_answer_options ALTER COLUMN id SET DEFAULT nextval('matrix_answer_options_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY matrix_answer_queries ALTER COLUMN id SET DEFAULT nextval('matrix_answer_queries_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY matrix_answer_query_fields ALTER COLUMN id SET DEFAULT nextval('matrix_answer_query_fields_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY matrix_answers ALTER COLUMN id SET DEFAULT nextval('matrix_answers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY multi_answer_option_fields ALTER COLUMN id SET DEFAULT nextval('multi_answer_option_fields_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY multi_answer_options ALTER COLUMN id SET DEFAULT nextval('multi_answer_options_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY multi_answers ALTER COLUMN id SET DEFAULT nextval('multi_answers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY numeric_answers ALTER COLUMN id SET DEFAULT nextval('numeric_answers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY other_fields ALTER COLUMN id SET DEFAULT nextval('other_fields_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY pdf_files ALTER COLUMN id SET DEFAULT nextval('pdf_files_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY persistent_errors ALTER COLUMN id SET DEFAULT nextval('persistent_errors_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY question_extras ALTER COLUMN id SET DEFAULT nextval('question_extras_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY question_fields ALTER COLUMN id SET DEFAULT nextval('question_fields_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY question_loop_types ALTER COLUMN id SET DEFAULT nextval('question_loop_types_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY questionnaire_fields ALTER COLUMN id SET DEFAULT nextval('questionnaire_fields_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY questionnaire_parts ALTER COLUMN id SET DEFAULT nextval('questionnaire_parts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY questionnaires ALTER COLUMN id SET DEFAULT nextval('questionnaires_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY questions ALTER COLUMN id SET DEFAULT nextval('questions_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY range_answer_option_fields ALTER COLUMN id SET DEFAULT nextval('range_answer_option_fields_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY range_answer_options ALTER COLUMN id SET DEFAULT nextval('range_answer_options_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY range_answers ALTER COLUMN id SET DEFAULT nextval('range_answers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY rank_answer_option_fields ALTER COLUMN id SET DEFAULT nextval('rank_answer_option_fields_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY rank_answer_options ALTER COLUMN id SET DEFAULT nextval('rank_answer_options_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY rank_answers ALTER COLUMN id SET DEFAULT nextval('rank_answers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY reminders ALTER COLUMN id SET DEFAULT nextval('reminders_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY roles ALTER COLUMN id SET DEFAULT nextval('roles_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY section_extras ALTER COLUMN id SET DEFAULT nextval('section_extras_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY section_fields ALTER COLUMN id SET DEFAULT nextval('section_fields_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY sections ALTER COLUMN id SET DEFAULT nextval('sections_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY source_files ALTER COLUMN id SET DEFAULT nextval('source_files_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY taggings ALTER COLUMN id SET DEFAULT nextval('taggings_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tags ALTER COLUMN id SET DEFAULT nextval('tags_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY text_answer_fields ALTER COLUMN id SET DEFAULT nextval('text_answer_fields_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY text_answers ALTER COLUMN id SET DEFAULT nextval('text_answers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_delegates ALTER COLUMN id SET DEFAULT nextval('user_delegates_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_filtering_fields ALTER COLUMN id SET DEFAULT nextval('user_filtering_fields_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_section_submission_states ALTER COLUMN id SET DEFAULT nextval('user_section_submission_states_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: alerts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY alerts
    ADD CONSTRAINT alerts_pkey PRIMARY KEY (id);


--
-- Name: answer_links_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY answer_links
    ADD CONSTRAINT answer_links_pkey PRIMARY KEY (id);


--
-- Name: answer_part_matrix_options_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY answer_part_matrix_options
    ADD CONSTRAINT answer_part_matrix_options_pkey PRIMARY KEY (id);


--
-- Name: answer_parts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY answer_parts
    ADD CONSTRAINT answer_parts_pkey PRIMARY KEY (id);


--
-- Name: answer_type_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY answer_type_fields
    ADD CONSTRAINT answer_type_fields_pkey PRIMARY KEY (id);


--
-- Name: answers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY answers
    ADD CONSTRAINT answers_pkey PRIMARY KEY (id);


--
-- Name: application_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY application_profiles
    ADD CONSTRAINT application_profiles_pkey PRIMARY KEY (id);


--
-- Name: assignments_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY assignments
    ADD CONSTRAINT assignments_pkey PRIMARY KEY (id);


--
-- Name: authorized_submitters_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY authorized_submitters
    ADD CONSTRAINT authorized_submitters_pkey PRIMARY KEY (id);


--
-- Name: csv_files_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY csv_files
    ADD CONSTRAINT csv_files_pkey PRIMARY KEY (id);


--
-- Name: deadlines_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY deadlines
    ADD CONSTRAINT deadlines_pkey PRIMARY KEY (id);


--
-- Name: delegate_text_answers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY delegate_text_answers
    ADD CONSTRAINT delegate_text_answers_pkey PRIMARY KEY (id);


--
-- Name: delegated_loop_item_names_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY delegated_loop_item_names
    ADD CONSTRAINT delegated_loop_item_names_pkey PRIMARY KEY (id);


--
-- Name: delegation_sections_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY delegation_sections
    ADD CONSTRAINT delegation_sections_pkey PRIMARY KEY (id);


--
-- Name: delegations_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY delegations
    ADD CONSTRAINT delegations_pkey PRIMARY KEY (id);


--
-- Name: documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY documents
    ADD CONSTRAINT documents_pkey PRIMARY KEY (id);


--
-- Name: extras_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY extras
    ADD CONSTRAINT extras_pkey PRIMARY KEY (id);


--
-- Name: filtering_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY filtering_fields
    ADD CONSTRAINT filtering_fields_pkey PRIMARY KEY (id);


--
-- Name: item_extra_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY item_extra_fields
    ADD CONSTRAINT item_extra_fields_pkey PRIMARY KEY (id);


--
-- Name: item_extras_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY item_extras
    ADD CONSTRAINT item_extras_pkey PRIMARY KEY (id);


--
-- Name: loop_item_name_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY loop_item_name_fields
    ADD CONSTRAINT loop_item_name_fields_pkey PRIMARY KEY (id);


--
-- Name: loop_item_names_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY loop_item_names
    ADD CONSTRAINT loop_item_names_pkey PRIMARY KEY (id);


--
-- Name: loop_item_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY loop_item_types
    ADD CONSTRAINT loop_item_types_pkey PRIMARY KEY (id);


--
-- Name: loop_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY loop_items
    ADD CONSTRAINT loop_items_pkey PRIMARY KEY (id);


--
-- Name: loop_sources_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY loop_sources
    ADD CONSTRAINT loop_sources_pkey PRIMARY KEY (id);


--
-- Name: matrix_answer_drop_option_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY matrix_answer_drop_option_fields
    ADD CONSTRAINT matrix_answer_drop_option_fields_pkey PRIMARY KEY (id);


--
-- Name: matrix_answer_drop_options_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY matrix_answer_drop_options
    ADD CONSTRAINT matrix_answer_drop_options_pkey PRIMARY KEY (id);


--
-- Name: matrix_answer_option_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY matrix_answer_option_fields
    ADD CONSTRAINT matrix_answer_option_fields_pkey PRIMARY KEY (id);


--
-- Name: matrix_answer_options_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY matrix_answer_options
    ADD CONSTRAINT matrix_answer_options_pkey PRIMARY KEY (id);


--
-- Name: matrix_answer_queries_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY matrix_answer_queries
    ADD CONSTRAINT matrix_answer_queries_pkey PRIMARY KEY (id);


--
-- Name: matrix_answer_query_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY matrix_answer_query_fields
    ADD CONSTRAINT matrix_answer_query_fields_pkey PRIMARY KEY (id);


--
-- Name: matrix_answers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY matrix_answers
    ADD CONSTRAINT matrix_answers_pkey PRIMARY KEY (id);


--
-- Name: multi_answer_option_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY multi_answer_option_fields
    ADD CONSTRAINT multi_answer_option_fields_pkey PRIMARY KEY (id);


--
-- Name: multi_answer_options_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY multi_answer_options
    ADD CONSTRAINT multi_answer_options_pkey PRIMARY KEY (id);


--
-- Name: multi_answers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY multi_answers
    ADD CONSTRAINT multi_answers_pkey PRIMARY KEY (id);


--
-- Name: numeric_answers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY numeric_answers
    ADD CONSTRAINT numeric_answers_pkey PRIMARY KEY (id);


--
-- Name: other_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY other_fields
    ADD CONSTRAINT other_fields_pkey PRIMARY KEY (id);


--
-- Name: pdf_files_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY pdf_files
    ADD CONSTRAINT pdf_files_pkey PRIMARY KEY (id);


--
-- Name: persistent_errors_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY persistent_errors
    ADD CONSTRAINT persistent_errors_pkey PRIMARY KEY (id);


--
-- Name: question_extras_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY question_extras
    ADD CONSTRAINT question_extras_pkey PRIMARY KEY (id);


--
-- Name: question_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY question_fields
    ADD CONSTRAINT question_fields_pkey PRIMARY KEY (id);


--
-- Name: question_loop_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY question_loop_types
    ADD CONSTRAINT question_loop_types_pkey PRIMARY KEY (id);


--
-- Name: questionnaire_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY questionnaire_fields
    ADD CONSTRAINT questionnaire_fields_pkey PRIMARY KEY (id);


--
-- Name: questionnaire_parts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY questionnaire_parts
    ADD CONSTRAINT questionnaire_parts_pkey PRIMARY KEY (id);


--
-- Name: questionnaires_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY questionnaires
    ADD CONSTRAINT questionnaires_pkey PRIMARY KEY (id);


--
-- Name: questions_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY questions
    ADD CONSTRAINT questions_pkey PRIMARY KEY (id);


--
-- Name: range_answer_option_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY range_answer_option_fields
    ADD CONSTRAINT range_answer_option_fields_pkey PRIMARY KEY (id);


--
-- Name: range_answer_options_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY range_answer_options
    ADD CONSTRAINT range_answer_options_pkey PRIMARY KEY (id);


--
-- Name: range_answers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY range_answers
    ADD CONSTRAINT range_answers_pkey PRIMARY KEY (id);


--
-- Name: rank_answer_option_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rank_answer_option_fields
    ADD CONSTRAINT rank_answer_option_fields_pkey PRIMARY KEY (id);


--
-- Name: rank_answer_options_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rank_answer_options
    ADD CONSTRAINT rank_answer_options_pkey PRIMARY KEY (id);


--
-- Name: rank_answers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY rank_answers
    ADD CONSTRAINT rank_answers_pkey PRIMARY KEY (id);


--
-- Name: reminders_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY reminders
    ADD CONSTRAINT reminders_pkey PRIMARY KEY (id);


--
-- Name: roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: section_extras_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY section_extras
    ADD CONSTRAINT section_extras_pkey PRIMARY KEY (id);


--
-- Name: section_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY section_fields
    ADD CONSTRAINT section_fields_pkey PRIMARY KEY (id);


--
-- Name: sections_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sections
    ADD CONSTRAINT sections_pkey PRIMARY KEY (id);


--
-- Name: source_files_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY source_files
    ADD CONSTRAINT source_files_pkey PRIMARY KEY (id);


--
-- Name: taggings_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY taggings
    ADD CONSTRAINT taggings_pkey PRIMARY KEY (id);


--
-- Name: tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: text_answer_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY text_answer_fields
    ADD CONSTRAINT text_answer_fields_pkey PRIMARY KEY (id);


--
-- Name: text_answers_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY text_answers
    ADD CONSTRAINT text_answers_pkey PRIMARY KEY (id);


--
-- Name: user_delegates_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_delegates
    ADD CONSTRAINT user_delegates_pkey PRIMARY KEY (id);


--
-- Name: user_filtering_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_filtering_fields
    ADD CONSTRAINT user_filtering_fields_pkey PRIMARY KEY (id);


--
-- Name: user_section_submission_states_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_section_submission_states
    ADD CONSTRAINT user_section_submission_states_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_answer_parts_on_field_type_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_answer_parts_on_field_type_id ON answer_parts USING btree (field_type_id);


--
-- Name: index_answers_on_question_id_and_user_id_and_looping_identifier; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_answers_on_question_id_and_user_id_and_looping_identifier ON answers USING btree (question_id, user_id, looping_identifier);


--
-- Name: index_documents_on_answer_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_documents_on_answer_id ON documents USING btree (answer_id);


--
-- Name: index_loop_item_types_on_parent_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_loop_item_types_on_parent_id ON loop_item_types USING btree (parent_id);


--
-- Name: index_loop_item_types_on_rgt; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_loop_item_types_on_rgt ON loop_item_types USING btree (rgt);


--
-- Name: index_loop_items_on_parent_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_loop_items_on_parent_id ON loop_items USING btree (parent_id);


--
-- Name: index_loop_items_on_rgt; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_loop_items_on_rgt ON loop_items USING btree (rgt);


--
-- Name: index_multi_answer_option_fields_on_language; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_multi_answer_option_fields_on_language ON multi_answer_option_fields USING btree (language);


--
-- Name: index_question_fields_on_question_id_and_language; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_question_fields_on_question_id_and_language ON question_fields USING btree (question_id, language);


--
-- Name: index_questionnaire_parts_on_parent_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_questionnaire_parts_on_parent_id ON questionnaire_parts USING btree (parent_id);


--
-- Name: index_questionnaire_parts_on_rgt; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_questionnaire_parts_on_rgt ON questionnaire_parts USING btree (rgt);


--
-- Name: index_section_fields_on_section_id_and_language; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_section_fields_on_section_id_and_language ON section_fields USING btree (section_id, language);


--
-- Name: index_sections_on_depends_on_question_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_sections_on_depends_on_question_id ON sections USING btree (depends_on_question_id);


--
-- Name: index_sections_on_loop_item_type_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_sections_on_loop_item_type_id ON sections USING btree (loop_item_type_id);


--
-- Name: index_taggings_on_tag_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_taggings_on_tag_id ON taggings USING btree (tag_id);


--
-- Name: index_taggings_on_taggable_id_and_taggable_type_and_context; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_taggings_on_taggable_id_and_taggable_type_and_context ON taggings USING btree (taggable_id, taggable_type, context);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: alerts_deadline_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY alerts
    ADD CONSTRAINT alerts_deadline_id_fk FOREIGN KEY (deadline_id) REFERENCES deadlines(id) ON DELETE CASCADE;


--
-- Name: alerts_reminder_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY alerts
    ADD CONSTRAINT alerts_reminder_id_fk FOREIGN KEY (reminder_id) REFERENCES reminders(id) ON DELETE CASCADE;


--
-- Name: answer_parts_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY answer_parts
    ADD CONSTRAINT answer_parts_original_id_fk FOREIGN KEY (original_id) REFERENCES answer_parts(id) ON DELETE SET NULL;


--
-- Name: answers_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY answers
    ADD CONSTRAINT answers_original_id_fk FOREIGN KEY (original_id) REFERENCES answers(id) ON DELETE SET NULL;


--
-- Name: deadlines_questionnaire_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY deadlines
    ADD CONSTRAINT deadlines_questionnaire_id_fk FOREIGN KEY (questionnaire_id) REFERENCES questionnaires(id) ON DELETE CASCADE;


--
-- Name: delegate_text_answers_answer_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY delegate_text_answers
    ADD CONSTRAINT delegate_text_answers_answer_id_fk FOREIGN KEY (answer_id) REFERENCES answers(id);


--
-- Name: delegate_text_answers_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY delegate_text_answers
    ADD CONSTRAINT delegate_text_answers_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: delegation_sections_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY delegation_sections
    ADD CONSTRAINT delegation_sections_original_id_fk FOREIGN KEY (original_id) REFERENCES delegation_sections(id) ON DELETE SET NULL;


--
-- Name: delegations_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY delegations
    ADD CONSTRAINT delegations_original_id_fk FOREIGN KEY (original_id) REFERENCES delegations(id) ON DELETE SET NULL;


--
-- Name: documents_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY documents
    ADD CONSTRAINT documents_original_id_fk FOREIGN KEY (original_id) REFERENCES documents(id) ON DELETE SET NULL;


--
-- Name: extras_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY extras
    ADD CONSTRAINT extras_original_id_fk FOREIGN KEY (original_id) REFERENCES extras(id) ON DELETE SET NULL;


--
-- Name: filtering_fields_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY filtering_fields
    ADD CONSTRAINT filtering_fields_original_id_fk FOREIGN KEY (original_id) REFERENCES filtering_fields(id) ON DELETE SET NULL;


--
-- Name: item_extras_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY item_extras
    ADD CONSTRAINT item_extras_original_id_fk FOREIGN KEY (original_id) REFERENCES item_extras(id) ON DELETE SET NULL;


--
-- Name: loop_item_names_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY loop_item_names
    ADD CONSTRAINT loop_item_names_original_id_fk FOREIGN KEY (original_id) REFERENCES loop_item_names(id) ON DELETE SET NULL;


--
-- Name: loop_item_types_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY loop_item_types
    ADD CONSTRAINT loop_item_types_original_id_fk FOREIGN KEY (original_id) REFERENCES loop_item_types(id) ON DELETE SET NULL;


--
-- Name: loop_items_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY loop_items
    ADD CONSTRAINT loop_items_original_id_fk FOREIGN KEY (original_id) REFERENCES loop_items(id) ON DELETE SET NULL;


--
-- Name: loop_sources_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY loop_sources
    ADD CONSTRAINT loop_sources_original_id_fk FOREIGN KEY (original_id) REFERENCES loop_sources(id) ON DELETE SET NULL;


--
-- Name: matrix_answer_drop_options_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY matrix_answer_drop_options
    ADD CONSTRAINT matrix_answer_drop_options_original_id_fk FOREIGN KEY (original_id) REFERENCES matrix_answer_drop_options(id) ON DELETE SET NULL;


--
-- Name: matrix_answer_options_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY matrix_answer_options
    ADD CONSTRAINT matrix_answer_options_original_id_fk FOREIGN KEY (original_id) REFERENCES matrix_answer_options(id) ON DELETE SET NULL;


--
-- Name: matrix_answer_queries_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY matrix_answer_queries
    ADD CONSTRAINT matrix_answer_queries_original_id_fk FOREIGN KEY (original_id) REFERENCES matrix_answer_queries(id) ON DELETE SET NULL;


--
-- Name: matrix_answers_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY matrix_answers
    ADD CONSTRAINT matrix_answers_original_id_fk FOREIGN KEY (original_id) REFERENCES matrix_answers(id) ON DELETE SET NULL;


--
-- Name: multi_answer_options_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY multi_answer_options
    ADD CONSTRAINT multi_answer_options_original_id_fk FOREIGN KEY (original_id) REFERENCES multi_answer_options(id) ON DELETE SET NULL;


--
-- Name: multi_answers_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY multi_answers
    ADD CONSTRAINT multi_answers_original_id_fk FOREIGN KEY (original_id) REFERENCES multi_answers(id) ON DELETE SET NULL;


--
-- Name: numeric_answers_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY numeric_answers
    ADD CONSTRAINT numeric_answers_original_id_fk FOREIGN KEY (original_id) REFERENCES numeric_answers(id) ON DELETE SET NULL;


--
-- Name: questionnaire_parts_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY questionnaire_parts
    ADD CONSTRAINT questionnaire_parts_original_id_fk FOREIGN KEY (original_id) REFERENCES questionnaire_parts(id) ON DELETE SET NULL;


--
-- Name: questionnaires_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY questionnaires
    ADD CONSTRAINT questionnaires_original_id_fk FOREIGN KEY (original_id) REFERENCES questionnaires(id) ON DELETE SET NULL;


--
-- Name: questions_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY questions
    ADD CONSTRAINT questions_original_id_fk FOREIGN KEY (original_id) REFERENCES questions(id) ON DELETE SET NULL;


--
-- Name: range_answer_options_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY range_answer_options
    ADD CONSTRAINT range_answer_options_original_id_fk FOREIGN KEY (original_id) REFERENCES range_answer_options(id) ON DELETE SET NULL;


--
-- Name: range_answers_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY range_answers
    ADD CONSTRAINT range_answers_original_id_fk FOREIGN KEY (original_id) REFERENCES range_answers(id) ON DELETE SET NULL;


--
-- Name: rank_answer_options_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rank_answer_options
    ADD CONSTRAINT rank_answer_options_original_id_fk FOREIGN KEY (original_id) REFERENCES rank_answer_options(id) ON DELETE SET NULL;


--
-- Name: rank_answers_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rank_answers
    ADD CONSTRAINT rank_answers_original_id_fk FOREIGN KEY (original_id) REFERENCES rank_answers(id) ON DELETE SET NULL;


--
-- Name: sections_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sections
    ADD CONSTRAINT sections_original_id_fk FOREIGN KEY (original_id) REFERENCES sections(id) ON DELETE SET NULL;


--
-- Name: text_answer_fields_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY text_answer_fields
    ADD CONSTRAINT text_answer_fields_original_id_fk FOREIGN KEY (original_id) REFERENCES text_answer_fields(id) ON DELETE SET NULL;


--
-- Name: text_answers_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY text_answers
    ADD CONSTRAINT text_answers_original_id_fk FOREIGN KEY (original_id) REFERENCES text_answers(id) ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

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