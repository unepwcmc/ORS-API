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
-- Name: binary_upgrade; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA binary_upgrade;


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


SET search_path = public, pg_catalog;

--
-- Name: answer_type; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE answer_type AS (
	answer_type_id integer,
	answer_type_type text
);


SET search_path = binary_upgrade, pg_catalog;

--
-- Name: create_empty_extension(text, text, boolean, text, oid[], text[], text[]); Type: FUNCTION; Schema: binary_upgrade; Owner: -
--

CREATE FUNCTION create_empty_extension(text, text, boolean, text, oid[], text[], text[]) RETURNS void
    LANGUAGE c
    AS '$libdir/pg_upgrade_support', 'create_empty_extension';


--
-- Name: set_next_array_pg_type_oid(oid); Type: FUNCTION; Schema: binary_upgrade; Owner: -
--

CREATE FUNCTION set_next_array_pg_type_oid(oid) RETURNS void
    LANGUAGE c STRICT
    AS '$libdir/pg_upgrade_support', 'set_next_array_pg_type_oid';


--
-- Name: set_next_heap_pg_class_oid(oid); Type: FUNCTION; Schema: binary_upgrade; Owner: -
--

CREATE FUNCTION set_next_heap_pg_class_oid(oid) RETURNS void
    LANGUAGE c STRICT
    AS '$libdir/pg_upgrade_support', 'set_next_heap_pg_class_oid';


--
-- Name: set_next_index_pg_class_oid(oid); Type: FUNCTION; Schema: binary_upgrade; Owner: -
--

CREATE FUNCTION set_next_index_pg_class_oid(oid) RETURNS void
    LANGUAGE c STRICT
    AS '$libdir/pg_upgrade_support', 'set_next_index_pg_class_oid';


--
-- Name: set_next_pg_authid_oid(oid); Type: FUNCTION; Schema: binary_upgrade; Owner: -
--

CREATE FUNCTION set_next_pg_authid_oid(oid) RETURNS void
    LANGUAGE c STRICT
    AS '$libdir/pg_upgrade_support', 'set_next_pg_authid_oid';


--
-- Name: set_next_pg_enum_oid(oid); Type: FUNCTION; Schema: binary_upgrade; Owner: -
--

CREATE FUNCTION set_next_pg_enum_oid(oid) RETURNS void
    LANGUAGE c STRICT
    AS '$libdir/pg_upgrade_support', 'set_next_pg_enum_oid';


--
-- Name: set_next_pg_type_oid(oid); Type: FUNCTION; Schema: binary_upgrade; Owner: -
--

CREATE FUNCTION set_next_pg_type_oid(oid) RETURNS void
    LANGUAGE c STRICT
    AS '$libdir/pg_upgrade_support', 'set_next_pg_type_oid';


--
-- Name: set_next_toast_pg_class_oid(oid); Type: FUNCTION; Schema: binary_upgrade; Owner: -
--

CREATE FUNCTION set_next_toast_pg_class_oid(oid) RETURNS void
    LANGUAGE c STRICT
    AS '$libdir/pg_upgrade_support', 'set_next_toast_pg_class_oid';


--
-- Name: set_next_toast_pg_type_oid(oid); Type: FUNCTION; Schema: binary_upgrade; Owner: -
--

CREATE FUNCTION set_next_toast_pg_type_oid(oid) RETURNS void
    LANGUAGE c STRICT
    AS '$libdir/pg_upgrade_support', 'set_next_toast_pg_type_oid';


SET search_path = public, pg_catalog;

--
-- Name: clone_questionnaire(integer, integer, boolean); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION clone_questionnaire(old_questionnaire_id integer, in_user_id integer, clone_answers boolean) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
  new_questionnaire_id INTEGER;
BEGIN
  SELECT * INTO new_questionnaire_id FROM copy_questionnaire(
    old_questionnaire_id, in_user_id
  );
  IF NOT FOUND THEN
    RAISE WARNING 'Unable to clone questionnaire %.', old_questionnaire_id;
    RETURN -1;
  END IF;

  PERFORM copy_authorized_submitters(old_questionnaire_id, new_questionnaire_id);
  PERFORM copy_questionnaire_parts_start(old_questionnaire_id, new_questionnaire_id);

  IF clone_answers THEN
    PERFORM copy_answers_start(old_questionnaire_id, new_questionnaire_id);
  END IF;

  PERFORM copy_questionnaire_parts_end();

  IF clone_answers THEN
    PERFORM copy_answers_end();
  END IF;

  RETURN new_questionnaire_id;
END;
$$;


--
-- Name: FUNCTION clone_questionnaire(old_questionnaire_id integer, in_user_id integer, clone_answers boolean); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION clone_questionnaire(old_questionnaire_id integer, in_user_id integer, clone_answers boolean) IS 'Procedure to create a deep copy of a questionnaire.';


--
-- Name: copy_answer_parts_end(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION copy_answer_parts_end() RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO answer_parts SELECT * FROM tmp_answer_parts;
  DROP TABLE tmp_answer_parts;
  INSERT INTO answer_part_matrix_options SELECT * FROM tmp_answer_part_matrix_options;
  DROP TABLE tmp_answer_part_matrix_options;
END;
$$;


--
-- Name: copy_answer_parts_start(integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION copy_answer_parts_start(old_questionnaire_id integer, new_questionnaire_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  CREATE TEMP TABLE tmp_answer_parts () INHERITS (answer_parts);
  CREATE TEMP TABLE tmp_answer_part_matrix_options () INHERITS (answer_part_matrix_options);

  WITH answer_parts_to_copy AS (
    SELECT
      answer_parts.*,
      tmp_answers.id AS new_answer_id,
      tmp_answers.created_at AS new_created_at,
      tmp_answers.updated_at AS new_updated_at
    FROM answer_parts
    JOIN tmp_answers
    ON tmp_answers.original_id = answer_parts.answer_id
  ), answer_parts_to_copy_with_resolved_field_types AS (
    SELECT answer_parts_to_copy.*, fields.id AS new_field_type_id
    FROM answer_parts_to_copy
    JOIN tmp_text_answer_fields fields
    ON answer_parts_to_copy.field_type_type = 'TextAnswerField'
    AND fields.original_id = answer_parts_to_copy.field_type_id

    UNION

    SELECT answer_parts_to_copy.*, fields.id AS new_field_type_id
    FROM answer_parts_to_copy
    JOIN tmp_numeric_answers fields
    ON answer_parts_to_copy.field_type_type = 'NumericAnswer'
    AND fields.original_id = answer_parts_to_copy.field_type_id

    UNION

    SELECT answer_parts_to_copy.*, fields.id AS new_field_type_id
    FROM answer_parts_to_copy
    JOIN tmp_rank_answer_options fields
    ON answer_parts_to_copy.field_type_type = 'RankAnswerOption'
    AND fields.original_id = answer_parts_to_copy.field_type_id

    UNION

    SELECT answer_parts_to_copy.*, fields.id AS new_field_type_id
    FROM answer_parts_to_copy
    JOIN tmp_range_answer_options fields
    ON answer_parts_to_copy.field_type_type = 'RangeAnswerOption'
    AND fields.original_id = answer_parts_to_copy.field_type_id

    UNION

    SELECT answer_parts_to_copy.*, fields.id AS new_field_type_id
    FROM answer_parts_to_copy
    JOIN tmp_multi_answer_options fields
    ON answer_parts_to_copy.field_type_type = 'MultiAnswerOption'
    AND fields.original_id = answer_parts_to_copy.field_type_id

    UNION

    SELECT answer_parts_to_copy.*, fields.id AS new_field_type_id
    FROM answer_parts_to_copy
    JOIN tmp_matrix_answer_queries fields
    ON answer_parts_to_copy.field_type_type = 'MatrixAnswerQuery'
    AND fields.original_id = answer_parts_to_copy.field_type_id
  )
  INSERT INTO tmp_answer_parts (
    answer_text,
    answer_id,
    field_type_type,
    field_type_id,
    details_text,
    answer_text_in_english,
    original_language,
    sort_index,
    created_at,
    updated_at,
    original_id
  )
  SELECT
    answer_text,
    new_answer_id,
    field_type_type,
    answer_parts.new_field_type_id,
    details_text,
    answer_text_in_english,
    original_language,
    sort_index,
    new_created_at,
    new_updated_at,
    answer_parts.id
  FROM answer_parts_to_copy_with_resolved_field_types answer_parts;

  INSERT INTO tmp_answer_part_matrix_options (
    answer_part_id,
    matrix_answer_option_id,
    matrix_answer_drop_option_id,
    answer_text,
    created_at,
    updated_at
  )
  SELECT
    tmp_answer_parts.id,
    tmp_matrix_answer_options.id,
    tmp_matrix_answer_drop_options.id,
    answer_part_matrix_options.answer_text,
    tmp_answer_parts.created_at,
    tmp_answer_parts.updated_at
  FROM answer_part_matrix_options
  JOIN tmp_answer_parts
  ON tmp_answer_parts.original_id = answer_part_matrix_options.answer_part_id
  LEFT JOIN tmp_matrix_answer_options
  ON tmp_matrix_answer_options.original_id = answer_part_matrix_options.matrix_answer_option_id
  LEFT JOIN tmp_matrix_answer_drop_options
  ON tmp_matrix_answer_drop_options.original_id = answer_part_matrix_options.matrix_answer_drop_option_id;
END;
$$;


--
-- Name: copy_answer_types_end(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION copy_answer_types_end() RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO text_answers SELECT * FROM tmp_text_answers;
  DROP TABLE tmp_text_answers;
  INSERT INTO text_answer_fields SELECT * FROM tmp_text_answer_fields;
  DROP TABLE tmp_text_answer_fields;
  INSERT INTO numeric_answers SELECT * FROM tmp_numeric_answers;
  DROP TABLE tmp_numeric_answers;
  INSERT INTO rank_answers SELECT * FROM tmp_rank_answers;
  DROP TABLE tmp_rank_answers;
  INSERT INTO rank_answer_options SELECT * FROM tmp_rank_answer_options;
  DROP TABLE tmp_rank_answer_options;
  INSERT INTO rank_answer_option_fields SELECT * FROM tmp_rank_answer_option_fields;
  DROP TABLE tmp_rank_answer_option_fields;
  INSERT INTO range_answers SELECT * FROM tmp_range_answers;
  DROP TABLE tmp_range_answers;
  INSERT INTO range_answer_options SELECT * FROM tmp_range_answer_options;
  DROP TABLE tmp_range_answer_options;
  INSERT INTO range_answer_option_fields SELECT * FROM tmp_range_answer_option_fields;
  DROP TABLE tmp_range_answer_option_fields;
  INSERT INTO multi_answers SELECT * FROM tmp_multi_answers;
  DROP TABLE tmp_multi_answers;
  INSERT INTO multi_answer_options SELECT * FROM tmp_multi_answer_options;
  DROP TABLE tmp_multi_answer_options;
  INSERT INTO multi_answer_option_fields SELECT * FROM tmp_multi_answer_option_fields;
  DROP TABLE tmp_multi_answer_option_fields;
  INSERT INTO tmp_other_fields SELECT * FROM tmp_other_fields;
  DROP TABLE tmp_other_fields;
  INSERT INTO matrix_answers SELECT * FROM tmp_matrix_answers;
  DROP TABLE tmp_matrix_answers;
  INSERT INTO matrix_answer_options SELECT * FROM tmp_matrix_answer_options;
  DROP TABLE tmp_matrix_answer_options;
  INSERT INTO matrix_answer_option_fields SELECT * FROM tmp_matrix_answer_option_fields;
  DROP TABLE tmp_matrix_answer_option_fields;
  INSERT INTO matrix_answer_drop_options SELECT * FROM tmp_matrix_answer_drop_options;
  DROP TABLE tmp_matrix_answer_drop_options;
  INSERT INTO matrix_answer_drop_option_fields SELECT * FROM tmp_matrix_answer_drop_option_fields;
  DROP TABLE tmp_matrix_answer_drop_option_fields;
  INSERT INTO matrix_answer_queries SELECT * FROM tmp_matrix_answer_queries;
  DROP TABLE tmp_matrix_answer_queries;
  INSERT INTO matrix_answer_query_fields SELECT * FROM tmp_matrix_answer_query_fields;
  DROP TABLE tmp_matrix_answer_query_fields;
  RETURN;
END;
$$;


--
-- Name: copy_answer_types_start(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION copy_answer_types_start(old_questionnaire_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  -- create temp tables to hold answer types for the duration of the cloning
  CREATE TEMP TABLE tmp_text_answers () INHERITS (text_answers);
  CREATE TEMP TABLE tmp_text_answer_fields () INHERITS (text_answer_fields);
  PERFORM copy_text_answers_to_tmp(old_questionnaire_id);
  CREATE TEMP TABLE tmp_numeric_answers () INHERITS (numeric_answers);
  PERFORM copy_numeric_answers_to_tmp(old_questionnaire_id);
  CREATE TEMP TABLE tmp_rank_answers () INHERITS (rank_answers);
  CREATE TEMP TABLE tmp_rank_answer_options () INHERITS (rank_answer_options);
  CREATE TEMP TABLE tmp_rank_answer_option_fields () INHERITS (rank_answer_option_fields);
  PERFORM copy_rank_answers_to_tmp(old_questionnaire_id);
  CREATE TEMP TABLE tmp_range_answers () INHERITS (range_answers);
  CREATE TEMP TABLE tmp_range_answer_options () INHERITS (range_answer_options);
  CREATE TEMP TABLE tmp_range_answer_option_fields () INHERITS (range_answer_option_fields);
  PERFORM copy_range_answers_to_tmp(old_questionnaire_id);
  CREATE TEMP TABLE tmp_multi_answers () INHERITS (multi_answers);
  CREATE TEMP TABLE tmp_multi_answer_options () INHERITS (multi_answer_options);
  CREATE TEMP TABLE tmp_multi_answer_option_fields () INHERITS (multi_answer_option_fields);
  CREATE TEMP TABLE tmp_other_fields () INHERITS (other_fields);
  PERFORM copy_multi_answers_to_tmp(old_questionnaire_id);
  CREATE TEMP TABLE tmp_matrix_answers () INHERITS (matrix_answers);
  CREATE TEMP TABLE tmp_matrix_answer_options () INHERITS (matrix_answer_options);
  CREATE TEMP TABLE tmp_matrix_answer_option_fields () INHERITS (matrix_answer_option_fields);
  CREATE TEMP TABLE tmp_matrix_answer_drop_options () INHERITS (matrix_answer_drop_options);
  CREATE TEMP TABLE tmp_matrix_answer_drop_option_fields () INHERITS (matrix_answer_drop_option_fields);
  CREATE TEMP TABLE tmp_matrix_answer_queries () INHERITS (matrix_answer_queries);
  CREATE TEMP TABLE tmp_matrix_answer_query_fields () INHERITS (matrix_answer_query_fields);
  PERFORM copy_matrix_answers_to_tmp(old_questionnaire_id);

  WITH answer_type_fields_with_resolved_ids AS (
    SELECT t.*, tmp_text_answers.id AS new_answer_type_id
    FROM tmp_text_answers
    JOIN answer_type_fields t
    ON t.answer_type_type = 'TextAnswer'
    AND t.answer_type_id = tmp_text_answers.original_id

    UNION

    SELECT t.*, tmp_numeric_answers.id AS new_answer_type_id
    FROM tmp_numeric_answers
    JOIN answer_type_fields t
    ON t.answer_type_type = 'NumericAnswer'
    AND t.answer_type_id = tmp_numeric_answers.original_id

    UNION

    SELECT t.*, tmp_rank_answers.id AS new_answer_type_id
    FROM tmp_rank_answers
    JOIN answer_type_fields t
    ON t.answer_type_type = 'RankAnswer'
    AND t.answer_type_id = tmp_rank_answers.original_id

    UNION

    SELECT t.*, tmp_range_answers.id AS new_answer_type_id
    FROM tmp_range_answers
    JOIN answer_type_fields t
    ON t.answer_type_type = 'RangeAnswer'
    AND t.answer_type_id = tmp_range_answers.original_id

    UNION

    SELECT t.*, tmp_multi_answers.id AS new_answer_type_id
    FROM tmp_multi_answers
    JOIN answer_type_fields t
    ON t.answer_type_type = 'MultiAnswer'
    AND t.answer_type_id = tmp_multi_answers.original_id

    UNION

    SELECT t.*, tmp_matrix_answers.id AS new_answer_type_id
    FROM tmp_matrix_answers
    JOIN answer_type_fields t
    ON t.answer_type_type = 'MatrixAnswer'
    AND t.answer_type_id = tmp_matrix_answers.original_id
  )
  INSERT INTO answer_type_fields (
    answer_type_type,
    answer_type_id,
    language,
    is_default_language,
    help_text,
    created_at,
    updated_at
  )
  SELECT
    answer_type_type,
    new_answer_type_id,
    language,
    is_default_language,
    help_text,
    current_timestamp,
    current_timestamp
  FROM answer_type_fields_with_resolved_ids;

  RETURN;
END;
$$;


--
-- Name: copy_answers_end(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION copy_answers_end() RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO answers SELECT * FROM tmp_answers;
  DROP TABLE tmp_answers;
  INSERT INTO documents SELECT * FROM tmp_documents;
  DROP TABLE tmp_documents;
  INSERT INTO answer_links SELECT * FROM tmp_answer_links;
  DROP TABLE tmp_answer_links;

  PERFORM copy_answer_parts_end();
END;
$$;


--
-- Name: copy_answers_start(integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION copy_answers_start(old_questionnaire_id integer, new_questionnaire_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  CREATE TEMP TABLE tmp_answers () INHERITS (answers);
  CREATE TEMP TABLE tmp_documents () INHERITS (documents);
  CREATE TEMP TABLE tmp_answer_links () INHERITS (answer_links);

  INSERT INTO tmp_answers (
    user_id,
    last_editor_id,
    questionnaire_id,
    question_id,
    loop_item_id,
    other_text,
    looping_identifier,
    from_dependent_section,
    created_at,
    updated_at,
    original_id
  )
  SELECT
    user_id,
    last_editor_id,
    new_questionnaire_id,
    question_id,
    loop_item_id,
    other_text,
    looping_identifier,
    from_dependent_section,
    created_at,
    updated_at,
    answers.id
  FROM answers
  WHERE answers.questionnaire_id = old_questionnaire_id;

  -- resolve questions
  UPDATE tmp_answers
  SET question_id = tmp_questions.id
  FROM tmp_questions
  WHERE tmp_questions.original_id = tmp_answers.question_id;

  -- resolve loop items
  UPDATE tmp_answers
  SET loop_item_id = tmp_loop_items.id
  FROM tmp_loop_items
  WHERE tmp_loop_items.original_id = tmp_answers.loop_item_id;

  -- now resolve the amazing looping identifiers
  WITH expanded_looping_identifiers AS (
    -- these subqueries ensure that we know the original order of loop items
    -- within the looping identifier
    SELECT answer_id, arr[pos]::INT AS loop_item_id, pos
    FROM  (
      SELECT *, GENERATE_SUBSCRIPTS(arr, 1) AS pos
      FROM  (
        SELECT id AS answer_id, STRING_TO_ARRAY(looping_identifier, 'S') AS arr
        FROM tmp_answers
      ) x
   ) y
  ), resolved_loop_item_ids AS (
    SELECT t.answer_id, t.loop_item_id, t.pos, tmp_loop_items.id AS new_loop_item_id
    FROM expanded_looping_identifiers t
    JOIN tmp_loop_items
    ON tmp_loop_items.original_id = t.loop_item_id
  ), resolved_looping_identifiers AS (
    SELECT
      resolved_loop_item_ids.answer_id,
      ARRAY_TO_STRING(ARRAY_AGG(new_loop_item_id::TEXT ORDER BY pos), 'S') AS new_looping_identifier
    FROM resolved_loop_item_ids
    GROUP BY answer_id
  )
  UPDATE tmp_answers
  SET looping_identifier = new_looping_identifier
  FROM resolved_looping_identifiers
  WHERE resolved_looping_identifiers.answer_id = tmp_answers.id;

  INSERT INTO tmp_answer_links (
    answer_id,
    url,
    description,
    title,
    created_at,
    updated_at
  )
  SELECT
    tmp_answers.id,
    url,
    description,
    title,
    tmp_answers.created_at,
    tmp_answers.updated_at
  FROM answer_links
  JOIN tmp_answers
  ON tmp_answers.original_id = answer_links.id;

  INSERT INTO tmp_documents (
    answer_id,
    doc_file_name,
    doc_content_type,
    doc_file_size,
    doc_updated_at,
    description,
    created_at,
    updated_at,
    original_id
  )
  SELECT
    tmp_answers.id,
    doc_file_name,
    doc_content_type,
    doc_file_size,
    doc_updated_at,
    description,
    tmp_answers.created_at,
    tmp_answers.updated_at,
    documents.id
  FROM documents
  JOIN tmp_answers
  ON tmp_answers.original_id = documents.answer_id;

  PERFORM copy_answer_parts_start(old_questionnaire_id, new_questionnaire_id);
END;
$$;


--
-- Name: copy_authorized_submitters(integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION copy_authorized_submitters(old_questionnaire_id integer, new_questionnaire_id integer) RETURNS void
    LANGUAGE sql
    AS $$

  INSERT INTO authorized_submitters (
    user_id,
    questionnaire_id,
    status,
    language,
    total_questions,
    answered_questions,
    requested_unsubmission,
    created_at,
    updated_at
  )
  SELECT
    user_id,
    new_questionnaire_id,
    1, --underway
    language,
    total_questions,
    answered_questions,
    requested_unsubmission,
    current_timestamp,
    current_timestamp
  FROM authorized_submitters
  WHERE questionnaire_id = old_questionnaire_id;

$$;


--
-- Name: copy_delegations_end(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION copy_delegations_end() RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO delegations
  SELECT * FROM tmp_delegations;
  DROP TABLE tmp_delegations;

  INSERT INTO delegation_sections
  SELECT * FROM tmp_delegation_sections;
  DROP TABLE tmp_delegation_sections;

  INSERT INTO delegated_loop_item_names
  SELECT * FROM tmp_delegated_loop_item_names;
  DROP TABLE tmp_delegated_loop_item_names;

  RETURN;
END;
$$;


--
-- Name: copy_delegations_start(integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION copy_delegations_start(old_questionnaire_id integer, new_questionnaire_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  CREATE TEMP TABLE tmp_delegations () INHERITS (delegations);
  CREATE TEMP TABLE tmp_delegation_sections () INHERITS (delegation_sections);
  CREATE TEMP TABLE tmp_delegated_loop_item_names () INHERITS (delegated_loop_item_names);

  INSERT INTO tmp_delegations (
    questionnaire_id,
    user_delegate_id,
    remarks,
    from_submission,
    created_at,
    updated_at,
    original_id
  )
  SELECT
    new_questionnaire_id,
    user_delegate_id,
    remarks,
    from_submission,
    current_timestamp,
    current_timestamp,
    delegations.id
  FROM delegations
  WHERE questionnaire_id = old_questionnaire_id;

  INSERT INTO tmp_delegation_sections (
    delegation_id,
    section_id,
    created_at,
    updated_at,
    original_id
  )
  SELECT
    tmp_delegations.id,
    tmp_sections.id,
    tmp_delegations.created_at,
    tmp_delegations.updated_at,
    delegation_sections.id
  FROM delegation_sections
  JOIN tmp_delegations
  ON tmp_delegations.original_id = delegation_sections.delegation_id
  JOIN tmp_sections
  ON tmp_sections.original_id = delegation_sections.section_id;

  INSERT INTO tmp_delegated_loop_item_names (
    delegation_section_id,
    loop_item_name_id,
    created_at,
    updated_at
  )
  SELECT
    tmp_delegation_sections.id,
    tmp_loop_item_names.id,
    tmp_delegation_sections.created_at,
    tmp_delegation_sections.updated_at
  FROM delegated_loop_item_names
  JOIN tmp_delegation_sections
  ON tmp_delegation_sections.original_id = delegated_loop_item_names.delegation_section_id
  JOIN tmp_loop_item_names
  ON tmp_loop_item_names.original_id = delegated_loop_item_names.loop_item_name_id;
END;
$$;


--
-- Name: copy_extras_end(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION copy_extras_end() RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO extras SELECT * FROM tmp_extras;
  DROP TABLE tmp_extras;
  INSERT INTO item_extras SELECT * FROM tmp_item_extras;
  DROP TABLE tmp_item_extras;
  INSERT INTO item_extra_fields SELECT * FROM tmp_item_extra_fields;
  DROP TABLE tmp_item_extra_fields;
  INSERT INTO section_extras SELECT * FROM tmp_section_extras;
  DROP TABLE tmp_section_extras;
  INSERT INTO question_extras SELECT * FROM tmp_question_extras;
  DROP TABLE tmp_question_extras;
END;
$$;


--
-- Name: copy_extras_start(integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION copy_extras_start(old_questionnaire_id integer, new_questionnaire_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  CREATE TEMP TABLE tmp_extras () INHERITS (extras);
  CREATE TEMP TABLE tmp_item_extras () INHERITS (item_extras);
  CREATE TEMP TABLE tmp_item_extra_fields () INHERITS (item_extra_fields);
  CREATE TEMP TABLE tmp_section_extras () INHERITS (section_extras);
  CREATE TEMP TABLE tmp_question_extras () INHERITS (question_extras);

  INSERT INTO tmp_extras (
    name,
    loop_item_type_id,
    field_type,
    created_at,
    updated_at,
    original_id
  )
  SELECT
    extras.name,
    tmp_loop_item_types.id,
    field_type,
    current_timestamp,
    current_timestamp,
    extras.id
  FROM extras
  JOIN tmp_loop_item_types
  ON tmp_loop_item_types.original_id = extras.loop_item_type_id;


  INSERT INTO tmp_item_extras (
    loop_item_name_id,
    extra_id,
    created_at,
    updated_at,
    original_id
  )
  SELECT
    tmp_loop_item_names.id,
    tmp_extras.id,
    current_timestamp,
    current_timestamp,
    item_extras.id
  FROM item_extras
  JOIN tmp_extras
  ON tmp_extras.original_id = item_extras.extra_id
  JOIN tmp_loop_item_names
  ON tmp_loop_item_names.original_id = item_extras.loop_item_name_id;

  INSERT INTO tmp_item_extra_fields (
    item_extra_id,
    language,
    value,
    is_default_language,
    created_at,
    updated_at
  )
  SELECT
    tmp_item_extras.id,
    language,
    value,
    is_default_language,
    current_timestamp,
    current_timestamp
  FROM item_extra_fields
  JOIN tmp_item_extras
  ON tmp_item_extras.original_id = item_extra_fields.item_extra_id;

  INSERT INTO tmp_section_extras (
    section_id,
    extra_id,
    created_at,
    updated_at
  )
  SELECT
    tmp_sections.id,
    tmp_extras.id,
    tmp_sections.created_at,
    tmp_sections.updated_at
  FROM section_extras
  JOIN tmp_sections
  ON tmp_sections.original_id = section_extras.section_id
  JOIN tmp_extras
  ON tmp_extras.original_id = section_extras.extra_id;

  INSERT INTO tmp_question_extras (
    question_id,
    extra_id,
    created_at,
    updated_at
  )
  SELECT
    tmp_questions.id,
    tmp_extras.id,
    tmp_questions.created_at,
    tmp_questions.updated_at
  FROM section_extras
  JOIN tmp_questions
  ON tmp_questions.original_id = section_extras.section_id
  JOIN tmp_extras
  ON tmp_extras.original_id = section_extras.extra_id;

END;
$$;


--
-- Name: copy_loop_items_end(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION copy_loop_items_end() RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO loop_item_names
  SELECT * FROM tmp_loop_item_names;
  DROP TABLE tmp_loop_item_names;

  INSERT INTO loop_item_name_fields
  SELECT * FROM tmp_loop_item_name_fields;
  DROP TABLE tmp_loop_item_name_fields;

  INSERT INTO loop_items SELECT * FROM tmp_loop_items;
  DROP TABLE tmp_loop_items;
END;
$$;


--
-- Name: copy_loop_items_start(integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION copy_loop_items_start(old_questionnaire_id integer, new_questionnaire_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  CREATE TEMP TABLE tmp_loop_item_names () INHERITS (loop_item_names);
  CREATE TEMP TABLE tmp_loop_item_name_fields () INHERITS (loop_item_name_fields);
  CREATE TEMP TABLE tmp_loop_items () INHERITS (loop_items);

  INSERT INTO tmp_loop_item_names (
    loop_source_id,
    loop_item_type_id,
    created_at,
    updated_at,
    original_id
  )
  SELECT
    tmp_loop_sources.id,
    tmp_loop_item_types.id,
    current_timestamp,
    current_timestamp,
    loop_item_names.id
  FROM loop_item_names
  JOIN tmp_loop_sources
  ON tmp_loop_sources.original_id = loop_item_names.loop_source_id
  JOIN tmp_loop_item_types
  ON tmp_loop_item_types.original_id = loop_item_names.loop_item_type_id;

  INSERT INTO tmp_loop_item_name_fields (
    loop_item_name_id,
    item_name,
    language,
    is_default_language,
    created_at,
    updated_at
  )
  SELECT
    tmp_loop_item_names.id,
    item_name,
    language,
    is_default_language,
    tmp_loop_item_names.created_at,
    tmp_loop_item_names.updated_at
  FROM loop_item_name_fields
  JOIN tmp_loop_item_names
  ON tmp_loop_item_names.original_id = loop_item_name_fields.loop_item_name_id;

  INSERT INTO tmp_loop_items (
    loop_item_type_id,
    loop_item_name_id,
    parent_id,
    lft,
    rgt,
    sort_index,
    created_at,
    updated_at,
    original_id
  )
  SELECT
    tmp_loop_item_types.id,
    tmp_loop_item_names.id,
    loop_items.parent_id,
    loop_items.lft,
    loop_items.rgt,
    sort_index,
    current_timestamp,
    current_timestamp,
    loop_items.id
  FROM loop_items
  JOIN tmp_loop_item_types
  ON tmp_loop_item_types.original_id = loop_items.loop_item_type_id
  JOIN tmp_loop_item_names
  ON tmp_loop_item_names.original_id = loop_items.loop_item_name_id;

  -- udate parent_id
  UPDATE tmp_loop_items
  SET parent_id = parents.id
  FROM tmp_loop_items parents
  WHERE parents.original_id = tmp_loop_items.parent_id;
  -- NOTE: run the acts_as_nested_set rebuild script afterwards to reset lft & rgt
END;
$$;


--
-- Name: copy_loop_sources_and_item_types_end(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION copy_loop_sources_and_item_types_end() RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO loop_sources
  SELECT * FROM tmp_loop_sources;
  DROP TABLE tmp_loop_sources;

  INSERT INTO source_files
  SELECT * FROM tmp_source_files;
  DROP TABLE tmp_source_files;

  INSERT INTO loop_item_types
  SELECT * FROM tmp_loop_item_types;
  DROP TABLE tmp_loop_item_types;
  RETURN;
END;
$$;


--
-- Name: copy_loop_sources_and_item_types_start(integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION copy_loop_sources_and_item_types_start(old_questionnaire_id integer, new_questionnaire_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  -- create temp tables to hold loop sources and answer types for the duration of the cloning
  CREATE TEMP TABLE tmp_loop_sources () INHERITS (loop_sources);
  CREATE TEMP TABLE tmp_source_files () INHERITS (source_files);
  CREATE TEMP TABLE tmp_loop_item_types () INHERITS (loop_item_types);

  INSERT INTO tmp_loop_sources(
    name,
    questionnaire_id,
    created_at,
    updated_at,
    original_id
  )
  SELECT
    name,
    new_questionnaire_id,
    current_timestamp,
    current_timestamp,
    loop_sources.id
  FROM loop_sources
  WHERE questionnaire_id = old_questionnaire_id;

  INSERT INTO tmp_source_files (
    loop_source_id,
    source_file_name,
    source_content_type,
    source_file_size,
    parse_status,
    source_updated_at,
    created_at,
    updated_at
  )
  SELECT
    tmp_loop_sources.id,
    source_file_name,
    source_content_type,
    source_file_size,
    parse_status,
    tmp_loop_sources.updated_at,
    tmp_loop_sources.created_at,
    tmp_loop_sources.updated_at
  FROM source_files
  JOIN tmp_loop_sources
  ON tmp_loop_sources.original_id = source_files.loop_source_id;

  WITH RECURSIVE copied_filtering_fields AS (
    INSERT INTO filtering_fields (
      name,
      questionnaire_id,
      created_at,
      updated_at,
      original_id
    )
    SELECT
      name,
      new_questionnaire_id,
      current_timestamp,
      current_timestamp,
      filtering_fields.id
    FROM filtering_fields
    WHERE questionnaire_id = old_questionnaire_id
    RETURNING *
  ), top_level_loop_item_types AS (
    SELECT loop_item_types.id, loop_source_id, filtering_field_id, loop_item_types.name, parent_id, lft, rgt
    FROM loop_item_types
    JOIN tmp_loop_sources
    ON tmp_loop_sources.original_id = loop_item_types.loop_source_id
    WHERE loop_item_types.parent_id IS NULL
  ), loop_item_types_tree AS (
    SELECT * FROM top_level_loop_item_types h
    UNION ALL
    SELECT hi.id, hi.loop_source_id, hi.filtering_field_id, hi.name, hi.parent_id, hi.lft, hi.rgt
    FROM loop_item_types hi
    JOIN loop_item_types_tree h ON h.id = hi.parent_id
  )
  INSERT INTO tmp_loop_item_types (
    loop_source_id,
    filtering_field_id,
    name,
    parent_id,
    lft,
    rgt,
    created_at,
    updated_at,
    original_id
  )
  SELECT
    tmp_loop_sources.id,
    copied_filtering_fields.id,
    loop_item_types.name,
    parent_id,
    lft,
    rgt,
    current_timestamp,
    current_timestamp,
    loop_item_types.id
  FROM loop_item_types_tree loop_item_types
  LEFT JOIN tmp_loop_sources
  ON tmp_loop_sources.original_id = loop_item_types.loop_source_id
  LEFT JOIN copied_filtering_fields
  ON copied_filtering_fields.original_id = loop_item_types.filtering_field_id;

  -- udate parent_id
  UPDATE tmp_loop_item_types
  SET parent_id = parents.id
  FROM tmp_loop_item_types parents
  WHERE parents.original_id = tmp_loop_item_types.parent_id;
  -- NOTE: run the acts_as_nested_set rebuild script afterwards to reset lft & rgt
  RETURN;
END;
$$;


--
-- Name: copy_matrix_answers_to_tmp(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION copy_matrix_answers_to_tmp(in_questionnaire_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  WITH matrix_answers_to_copy AS (
    SELECT * FROM questionnaire_answer_types(in_questionnaire_id, 'MatrixAnswer')
  )
  INSERT INTO tmp_matrix_answers (
    display_reply,
    matrix_orientation,
    created_at,
    updated_at,
    original_id
  )
  SELECT
    display_reply,
    matrix_orientation,
    current_timestamp,
    current_timestamp,
    matrix_answers.id
  FROM matrix_answers
  JOIN matrix_answers_to_copy t
  ON t.answer_type_id = matrix_answers.id;

  WITH copied_matrix_answer_options AS (
    INSERT INTO tmp_matrix_answer_options (
      matrix_answer_id,
      created_at,
      updated_at,
      original_id
    )
    SELECT
      tmp_matrix_answers.id,
      current_timestamp,
      current_timestamp,
      t.id
    FROM matrix_answer_options t
    JOIN tmp_matrix_answers
    ON tmp_matrix_answers.original_id = t.matrix_answer_id
    RETURNING *
  )
  INSERT INTO tmp_matrix_answer_option_fields (
    matrix_answer_option_id,
    language,
    title,
    is_default_language,
    created_at,
    updated_at
  )
  SELECT
    copied_matrix_answer_options.id,
    language,
    title,
    is_default_language,
    current_timestamp,
    current_timestamp
  FROM matrix_answer_option_fields t
  JOIN copied_matrix_answer_options
  ON copied_matrix_answer_options.original_id = t.matrix_answer_option_id;

  WITH copied_matrix_answer_drop_options AS (
    INSERT INTO tmp_matrix_answer_drop_options (
      matrix_answer_id,
      created_at,
      updated_at,
      original_id
    )
    SELECT
      tmp_matrix_answers.id,
      current_timestamp,
      current_timestamp,
      t.id
    FROM matrix_answer_drop_options t
    JOIN tmp_matrix_answers
    ON tmp_matrix_answers.original_id = t.matrix_answer_id
    RETURNING *
  )
  INSERT INTO tmp_matrix_answer_drop_option_fields (
    matrix_answer_drop_option_id,
    language,
    is_default_language,
    option_text,
    created_at,
    updated_at
  )
  SELECT
    copied_matrix_answer_drop_options.id,
    language,
    is_default_language,
    option_text,
    current_timestamp,
    current_timestamp
  FROM matrix_answer_drop_option_fields t
  JOIN copied_matrix_answer_drop_options
  ON copied_matrix_answer_drop_options.original_id = t.matrix_answer_drop_option_id;

  INSERT INTO tmp_matrix_answer_queries (
    matrix_answer_id,
    created_at,
    updated_at,
    original_id
  )
  SELECT
    tmp_matrix_answers.id,
    current_timestamp,
    current_timestamp,
    t.id
  FROM matrix_answer_queries t
  JOIN tmp_matrix_answers
  ON tmp_matrix_answers.original_id = t.matrix_answer_id;

  INSERT INTO tmp_matrix_answer_query_fields (
    matrix_answer_query_id,
    language,
    title,
    is_default_language,
    created_at,
    updated_at
  )
  SELECT
    tmp_matrix_answer_queries.id,
    language,
    title,
    is_default_language,
    current_timestamp,
    current_timestamp
  FROM matrix_answer_query_fields t
  JOIN tmp_matrix_answer_queries
  ON tmp_matrix_answer_queries.original_id = t.matrix_answer_query_id;

  RETURN;
END;
$$;


--
-- Name: copy_multi_answers_to_tmp(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION copy_multi_answers_to_tmp(in_questionnaire_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  WITH multi_answers_to_copy AS (
    SELECT * FROM questionnaire_answer_types(in_questionnaire_id, 'MultiAnswer')
  )
  INSERT INTO tmp_multi_answers (
    single,
    other_required,
    display_type,
    created_at,
    updated_at,
    original_id
  )
  SELECT
    single,
    other_required,
    display_type,
    multi_answers.created_at,
    current_timestamp,
    multi_answers.id
  FROM multi_answers
  JOIN multi_answers_to_copy t
  ON t.answer_type_id = multi_answers.id;

  INSERT INTO tmp_multi_answer_options (
    multi_answer_id,
    details_field,
    sort_index,
    created_at,
    updated_at,
    original_id
  )
  SELECT
    tmp_multi_answers.id,
    details_field,
    sort_index,
    tmp_multi_answers.created_at,
    tmp_multi_answers.updated_at,
    t.id
  FROM multi_answer_options t
  JOIN tmp_multi_answers
  ON tmp_multi_answers.original_id = t.multi_answer_id;

  INSERT INTO tmp_multi_answer_option_fields (
    multi_answer_option_id,
    option_text,
    language,
    is_default_language,
    created_at,
    updated_at
  )
  SELECT
    tmp_multi_answer_options.id,
    option_text,
    language,
    is_default_language,
    tmp_multi_answer_options.created_at,
    tmp_multi_answer_options.updated_at
  FROM multi_answer_option_fields t
  JOIN tmp_multi_answer_options
  ON tmp_multi_answer_options.original_id = t.multi_answer_option_id;

  INSERT INTO tmp_other_fields (
    multi_answer_id,
    other_text,
    language,
    is_default_language,
    created_at,
    updated_at
  )
  SELECT
    tmp_multi_answers.id,
    other_text,
    language,
    is_default_language,
    tmp_multi_answers.created_at,
    tmp_multi_answers.updated_at
  FROM other_fields
  JOIN tmp_multi_answers
  ON tmp_multi_answers.original_id = other_fields.multi_answer_id;
  RETURN;
END;
$$;


--
-- Name: copy_numeric_answers_to_tmp(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION copy_numeric_answers_to_tmp(in_questionnaire_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  WITH numeric_answers_to_copy AS (
    SELECT * FROM questionnaire_answer_types(in_questionnaire_id, 'NumericAnswer')
  )
  INSERT INTO tmp_numeric_answers (
    created_at,
    updated_at,
    original_id
  )
  SELECT
    current_timestamp,
    current_timestamp,
    numeric_answers.id
  FROM numeric_answers
  JOIN numeric_answers_to_copy t
  ON t.answer_type_id = numeric_answers.id;
  RETURN;
END;
$$;


--
-- Name: copy_questionnaire(integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION copy_questionnaire(in_questionnaire_id integer, in_user_id integer) RETURNS integer
    LANGUAGE sql
    AS $$
  WITH copied_questionnaires AS (
    INSERT INTO questionnaires (
      user_id,
      last_editor_id,
      administrator_remarks,
      questionnaire_date,
      header_file_name,
      header_content_type,
      header_file_size,
      header_updated_at,
      status,
      display_in_tab_max_level,
      delegation_enabled,
      help_pages,
      translator_visible,
      private_documents,
      created_at,
      updated_at,
      activated_at,
      last_edited,
      original_id
    )
    SELECT
      in_user_id,
      in_user_id,
      administrator_remarks,
      questionnaire_date,
      header_file_name,
      header_content_type,
      header_file_size,
      header_updated_at,
      0, -- not started
      display_in_tab_max_level,
      delegation_enabled,
      help_pages,
      translator_visible,
      private_documents,
      current_timestamp,
      current_timestamp,
      NULL,
      NULL,
      id
    FROM questionnaires
    WHERE id = in_questionnaire_id
    RETURNING *
  ), copied_questionnaire_fields AS (
    INSERT INTO questionnaire_fields (
      questionnaire_id,
      language,
      title,
      introductory_remarks,
      is_default_language,
      email_subject,
      email,
      email_footer,
      submit_info_tip,
      created_at,
      updated_at
    )
    SELECT
      copied_questionnaires.id,
      t.language,
      'COPY ' || TO_CHAR(copied_questionnaires.created_at, 'DD/MM/YYYY') || ': ' || t.title,
      t.introductory_remarks,
      t.is_default_language,
      t.email_subject,
      t.email,
      t.email_footer,
      t.submit_info_tip,
      copied_questionnaires.created_at,
      copied_questionnaires.updated_at
    FROM questionnaire_fields t
    JOIN copied_questionnaires
    ON copied_questionnaires.original_id = t.questionnaire_id
  )
  SELECT id FROM copied_questionnaires;
$$;


--
-- Name: copy_questionnaire_parts_end(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION copy_questionnaire_parts_end() RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  PERFORM copy_loop_sources_and_item_types_end();
  PERFORM copy_answer_types_end();
  PERFORM copy_sections_end();
  PERFORM copy_questions_end();
  PERFORM resolve_dependent_sections_end();
  PERFORM copy_loop_items_end();
  PERFORM copy_extras_end();
  PERFORM copy_delegations_end();

  -- insert into questionnaire_parts
  INSERT INTO questionnaire_parts SELECT * FROM tmp_questionnaire_parts;
  DROP TABLE tmp_questionnaire_parts;
END;
$$;


--
-- Name: copy_questionnaire_parts_start(integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION copy_questionnaire_parts_start(old_questionnaire_id integer, new_questionnaire_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  -- use a temporary table to isolate the copied questionnaire_parts tree
  -- while resolving parent_id and part_id
  CREATE TEMP TABLE tmp_questionnaire_parts () INHERITS (questionnaire_parts);

  -- the truly amazing thing is: this table will use the same sequence
  -- to generate primary keys as the master table
  INSERT INTO tmp_questionnaire_parts (
    questionnaire_id,
    part_id,
    part_type,
    created_at,
    updated_at,
    parent_id,
    lft,
    rgt,
    original_id
  )
  SELECT
    CASE
      WHEN questionnaire_id IS NULL THEN NULL
      ELSE new_questionnaire_id
    END AS questionnaire_id,
    part_id,
    part_type,
    current_timestamp AS created_at,
    current_timestamp AS updated_at,
    parent_id,
    lft,
    rgt,
    parts.id AS original_id
  FROM questionnaire_parts_with_descendents(old_questionnaire_id) parts;

  -- udate parent_id
  UPDATE tmp_questionnaire_parts
  SET parent_id = parents.id
  FROM tmp_questionnaire_parts parents
  WHERE parents.original_id = tmp_questionnaire_parts.parent_id;
  -- NOTE: run the acts_as_nested_set rebuild script afterwards to reset lft & rgt

  PERFORM copy_answer_types_start(old_questionnaire_id);
  PERFORM copy_loop_sources_and_item_types_start(old_questionnaire_id, new_questionnaire_id);
  PERFORM copy_loop_items_start(old_questionnaire_id, new_questionnaire_id);
  PERFORM copy_sections_start(old_questionnaire_id);
  PERFORM copy_questions_start(old_questionnaire_id);
  PERFORM resolve_dependent_sections_start();
  PERFORM copy_extras_start(old_questionnaire_id, new_questionnaire_id);
  PERFORM copy_delegations_start(old_questionnaire_id, new_questionnaire_id);

  UPDATE tmp_questionnaire_parts
  SET part_id = tmp_sections.id
  FROM tmp_sections
  WHERE tmp_sections.original_id = tmp_questionnaire_parts.part_id
    AND tmp_questionnaire_parts.part_type = 'Section';

  UPDATE tmp_questionnaire_parts
  SET part_id = tmp_questions.id
  FROM tmp_questions
  WHERE tmp_questions.original_id = tmp_questionnaire_parts.part_id
    AND tmp_questionnaire_parts.part_type = 'Question';
  RETURN;

END;
$$;


--
-- Name: copy_questions_end(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION copy_questions_end() RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO questions SELECT * FROM tmp_questions;
  DROP TABLE tmp_questions;
  INSERT INTO question_fields SELECT * FROM tmp_question_fields;
  DROP TABLE tmp_question_fields;
  INSERT INTO question_loop_types SELECT * FROM tmp_question_loop_types;
  DROP TABLE tmp_question_loop_types;
END;
$$;


--
-- Name: copy_questions_start(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION copy_questions_start(old_questionnaire_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN

  CREATE TEMP TABLE tmp_questions () INHERITS (questions);
  CREATE TEMP TABLE tmp_question_fields () INHERITS (question_fields);
  CREATE TEMP TABLE tmp_question_loop_types () INHERITS (question_loop_types);

  WITH questions_to_copy AS (
    SELECT * FROM questionnaire_questions(old_questionnaire_id)
  ), questions_to_copy_with_resolved_answer_types AS (
    SELECT questions_to_copy.*, tmp.id AS new_answer_type_id
    FROM questions_to_copy
    JOIN tmp_text_answers tmp
    ON questions_to_copy.answer_type_type = 'TextAnswer'
    AND tmp.original_id = questions_to_copy.answer_type_id

    UNION

    SELECT questions_to_copy.*, tmp.id AS new_answer_type_id
    FROM questions_to_copy
    JOIN tmp_numeric_answers tmp
    ON questions_to_copy.answer_type_type = 'NumericAnswer'
    AND tmp.original_id = questions_to_copy.answer_type_id

    UNION

    SELECT questions_to_copy.*, tmp.id AS new_answer_type_id
    FROM questions_to_copy
    JOIN tmp_rank_answers tmp
    ON questions_to_copy.answer_type_type = 'RankAnswer'
    AND tmp.original_id = questions_to_copy.answer_type_id

    UNION

    SELECT questions_to_copy.*, tmp.id AS new_answer_type_id
    FROM questions_to_copy
    JOIN tmp_range_answers tmp
    ON questions_to_copy.answer_type_type = 'RangeAnswer'
    AND tmp.original_id = questions_to_copy.answer_type_id

    UNION

    SELECT questions_to_copy.*, tmp.id AS new_answer_type_id
    FROM questions_to_copy
    JOIN tmp_multi_answers tmp
    ON questions_to_copy.answer_type_type = 'MultiAnswer'
    AND tmp.original_id = questions_to_copy.answer_type_id

    UNION

    SELECT questions_to_copy.*, tmp.id AS new_answer_type_id
    FROM questions_to_copy
    JOIN tmp_matrix_answers tmp
    ON questions_to_copy.answer_type_type = 'MatrixAnswer'
    AND tmp.original_id = questions_to_copy.answer_type_id
  )
  INSERT INTO tmp_questions (
    section_id,
    answer_type_id,
    answer_type_type,
    is_mandatory,
    created_at,
    updated_at,
    last_edited,
    original_id
  )
  SELECT
    tmp_sections.id,
    new_answer_type_id,
    t.answer_type_type,
    is_mandatory,
    current_timestamp,
    current_timestamp,
    NULL,
    t.id
  FROM questions_to_copy_with_resolved_answer_types t
  JOIN tmp_sections
  ON tmp_sections.original_id = t.section_id;

  INSERT INTO tmp_question_fields (
    title,
    short_title,
    language,
    description,
    question_id,
    created_at,
    updated_at,
    is_default_language
  )
  SELECT
    title,
    short_title,
    language,
    description,
    tmp_questions.id,
    current_timestamp,
    current_timestamp,
    is_default_language
  FROM question_fields t
  JOIN tmp_questions
  ON tmp_questions.original_id = t.question_id;

  INSERT INTO tmp_question_loop_types (
    question_id,
    loop_item_type_id,
    created_at,
    updated_at
  )
  SELECT
    tmp_questions.id,
    tmp_loop_item_types.id,
    tmp_questions.created_at,
    tmp_questions.updated_at
  FROM question_loop_types
  JOIN tmp_questions
  ON tmp_questions.original_id = question_loop_types.question_id
  JOIN tmp_loop_item_types
  ON tmp_loop_item_types.original_id = question_loop_types.loop_item_type_id;

END;
$$;


--
-- Name: copy_range_answers_to_tmp(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION copy_range_answers_to_tmp(in_questionnaire_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  WITH range_answers_to_copy AS (
    SELECT * FROM questionnaire_answer_types(in_questionnaire_id, 'RangeAnswer')
  )
  INSERT INTO tmp_range_answers (
    created_at,
    updated_at,
    original_id
  )
  SELECT
    current_timestamp,
    current_timestamp,
    range_answers.id
  FROM range_answers
  JOIN range_answers_to_copy t
  ON t.answer_type_id = range_answers.id;

  INSERT INTO tmp_range_answer_options (
    range_answer_id,
    sort_index,
    created_at,
    updated_at,
    original_id
  )
  SELECT
    tmp_range_answers.id,
    sort_index,
    tmp_range_answers.created_at,
    tmp_range_answers.updated_at,
    t.id
  FROM range_answer_options t
  JOIN tmp_range_answers
  ON tmp_range_answers.original_id = t.range_answer_id;

  INSERT INTO tmp_range_answer_option_fields (
    range_answer_option_id,
    option_text,
    language,
    is_default_language,
    created_at,
    updated_at
  )
  SELECT
    tmp_range_answer_options.id,
    option_text,
    language,
    is_default_language,
    tmp_range_answer_options.created_at,
    tmp_range_answer_options.updated_at
  FROM range_answer_option_fields t
  JOIN tmp_range_answer_options
  ON tmp_range_answer_options.original_id = t.range_answer_option_id;

  RETURN;
END;
$$;


--
-- Name: copy_rank_answers_to_tmp(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION copy_rank_answers_to_tmp(in_questionnaire_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  WITH rank_answers_to_copy AS (
    SELECT * FROM questionnaire_answer_types(in_questionnaire_id, 'RankAnswer')
  )
  INSERT INTO tmp_rank_answers (
    maximum_choices,
    created_at,
    updated_at,
    original_id
  )
  SELECT
    maximum_choices,
    current_timestamp,
    current_timestamp,
    rank_answers.id
  FROM rank_answers
  JOIN rank_answers_to_copy t
  ON t.answer_type_id = rank_answers.id;

  INSERT INTO tmp_rank_answer_options (
    rank_answer_id,
    created_at,
    updated_at,
    original_id
  )
  SELECT
    tmp_rank_answers.id,
    tmp_rank_answers.created_at,
    tmp_rank_answers.updated_at,
    t.id
  FROM rank_answer_options t
  JOIN tmp_rank_answers
  ON tmp_rank_answers.original_id = t.rank_answer_id;

  INSERT INTO tmp_rank_answer_option_fields (
    rank_answer_option_id,
    language,
    option_text,
    is_default_language,
    created_at,
    updated_at
  )
  SELECT
    tmp_rank_answer_options.id,
    language,
    option_text,
    is_default_language,
    tmp_rank_answer_options.created_at,
    tmp_rank_answer_options.updated_at
  FROM rank_answer_option_fields t
  JOIN tmp_rank_answer_options
  ON tmp_rank_answer_options.original_id = t.rank_answer_option_id;

  RETURN;
END;
$$;


--
-- Name: copy_sections_end(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION copy_sections_end() RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO sections SELECT * FROM tmp_sections;
  DROP TABLE tmp_sections;
  INSERT INTO section_fields SELECT * FROM tmp_section_fields;
  DROP TABLE tmp_section_fields;
END;
$$;


--
-- Name: copy_sections_start(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION copy_sections_start(in_questionnaire_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  CREATE TEMP TABLE tmp_sections () INHERITS (sections);
  CREATE TEMP TABLE tmp_section_fields () INHERITS (section_fields);

  WITH sections_to_copy AS (
    SELECT * FROM questionnaire_sections(in_questionnaire_id)
  ), sections_to_copy_with_resolved_answer_types AS (
    SELECT sections_to_copy.*, NULL AS new_answer_type_id
    FROM sections_to_copy
    WHERE answer_type_id IS NULL

    UNION

    SELECT sections_to_copy.*, tmp.id AS new_answer_type_id
    FROM sections_to_copy
    JOIN tmp_text_answers tmp
    ON sections_to_copy.answer_type_type = 'TextAnswer'
    AND tmp.original_id = sections_to_copy.answer_type_id

    UNION

    SELECT sections_to_copy.*, tmp.id AS new_answer_type_id
    FROM sections_to_copy
    JOIN tmp_numeric_answers tmp
    ON sections_to_copy.answer_type_type = 'NumericAnswer'
    AND tmp.original_id = sections_to_copy.answer_type_id

    UNION

    SELECT sections_to_copy.*, tmp.id AS new_answer_type_id
    FROM sections_to_copy
    JOIN tmp_rank_answers tmp
    ON sections_to_copy.answer_type_type = 'RankAnswer'
    AND tmp.original_id = sections_to_copy.answer_type_id

    UNION

    SELECT sections_to_copy.*, tmp.id AS new_answer_type_id
    FROM sections_to_copy
    JOIN tmp_range_answers tmp
    ON sections_to_copy.answer_type_type = 'RangeAnswer'
    AND tmp.original_id = sections_to_copy.answer_type_id

    UNION

    SELECT sections_to_copy.*, tmp.id AS new_answer_type_id
    FROM sections_to_copy
    JOIN tmp_multi_answers tmp
    ON sections_to_copy.answer_type_type = 'MultiAnswer'
    AND tmp.original_id = sections_to_copy.answer_type_id

    UNION

    SELECT sections_to_copy.*, tmp.id AS new_answer_type_id
    FROM sections_to_copy
    JOIN tmp_matrix_answers tmp
    ON sections_to_copy.answer_type_type = 'MatrixAnswer'
    AND tmp.original_id = sections_to_copy.answer_type_id
  ), sections_to_copy_with_resolved_loop_source_and_item_type AS (
    SELECT sections_to_copy.*,
    tmp_loop_sources.id AS new_loop_source_id,
    tmp_loop_item_types.id AS new_loop_item_type_id
    FROM sections_to_copy_with_resolved_answer_types sections_to_copy
    LEFT JOIN tmp_loop_item_types
    ON tmp_loop_item_types.original_id = sections_to_copy.loop_item_type_id
    LEFT JOIN tmp_loop_sources
    ON tmp_loop_sources.original_id = sections_to_copy.loop_source_id
  )
  INSERT INTO tmp_sections (
    section_type,
    answer_type_id,
    answer_type_type,
    loop_source_id,
    loop_item_type_id,
    depends_on_option_id,
    depends_on_option_value,
    depends_on_question_id,
    is_hidden,
    starts_collapsed,
    display_in_tab,
    created_at,
    updated_at,
    last_edited,
    original_id
  )
  SELECT
    section_type,
    new_answer_type_id,
    answer_type_type,
    new_loop_source_id,
    new_loop_item_type_id,
    depends_on_option_id,
    depends_on_option_value,
    depends_on_question_id,
    is_hidden,
    starts_collapsed,
    display_in_tab,
    current_timestamp,
    current_timestamp,
    NULL,
    id
  FROM sections_to_copy_with_resolved_loop_source_and_item_type;

  -- copy section fields
  INSERT INTO tmp_section_fields (
    title,
    language,
    description,
    section_id,
    created_at,
    updated_at,
    is_default_language,
    tab_title
  )
  SELECT
    title,
    language,
    description,
    tmp_sections.id,
    current_timestamp,
    current_timestamp,
    is_default_language,
    tab_title
  FROM section_fields t
  JOIN tmp_sections
  ON tmp_sections.original_id = t.section_id;
END;
$$;


--
-- Name: copy_text_answers_to_tmp(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION copy_text_answers_to_tmp(in_questionnaire_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  WITH text_answers_to_copy AS (
    SELECT * FROM questionnaire_answer_types(in_questionnaire_id, 'TextAnswer')
  )
  INSERT INTO tmp_text_answers (
    created_at,
    updated_at,
    original_id
  )
  SELECT
    current_timestamp,
    current_timestamp,
    text_answers.id
  FROM text_answers
  JOIN text_answers_to_copy t
  ON t.answer_type_id = text_answers.id;

  INSERT INTO tmp_text_answer_fields (
    text_answer_id,
    rows,
    width,
    created_at,
    updated_at,
    original_id
  )
  SELECT
    tmp_text_answers.id,
    rows,
    width,
    tmp_text_answers.created_at,
    tmp_text_answers.updated_at,
    t.id
  FROM text_answer_fields t
  JOIN tmp_text_answers
  ON tmp_text_answers.original_id = t.text_answer_id;

  RETURN;
END;
$$;


--
-- Name: questionnaire_answer_types(integer, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION questionnaire_answer_types(in_questionnaire_id integer, in_answer_type text) RETURNS SETOF answer_type
    LANGUAGE sql
    AS $$
  WITH questionnaire_parts_to_copy AS (
    SELECT * FROM questionnaire_parts_with_descendents(in_questionnaire_id)
  )
  SELECT answer_type_id, in_answer_type FROM (
    SELECT answer_type_id
    FROM sections
    JOIN questionnaire_parts_to_copy t
    ON t.part_type = 'Section' AND t.part_id = sections.id
    WHERE sections.answer_type_type = in_answer_type
    UNION
    SELECT answer_type_id
    FROM questions
    JOIN questionnaire_parts_to_copy t
    ON t.part_type = 'Question' AND t.part_id = questions.id
    WHERE questions.answer_type_type = in_answer_type
  ) t
  GROUP BY answer_type_id
$$;


SET default_tablespace = '';

SET default_with_oids = false;

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
-- Name: questions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE questions (
    id integer NOT NULL,
    uidentifier character varying(255),
    last_edited timestamp without time zone,
    section_id integer NOT NULL,
    answer_type_id integer,
    answer_type_type character varying(255) DEFAULT NULL::character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    is_mandatory boolean DEFAULT false,
    allow_attachments boolean DEFAULT true,
    original_id integer
);


--
-- Name: questionnaire_questions(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION questionnaire_questions(in_questionnaire_id integer) RETURNS SETOF questions
    LANGUAGE sql
    AS $$

  WITH question_parts AS (
    SELECT * FROM questionnaire_parts_with_descendents(in_questionnaire_id)
    WHERE part_type = 'Question'
  )
  SELECT questions.*
  FROM question_parts
  JOIN questions ON questions.id = part_id
$$;


--
-- Name: sections; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sections (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    last_edited timestamp without time zone,
    section_type integer NOT NULL,
    answer_type_id integer,
    answer_type_type character varying(255) DEFAULT NULL::character varying,
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
-- Name: questionnaire_sections(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION questionnaire_sections(in_questionnaire_id integer) RETURNS SETOF sections
    LANGUAGE sql
    AS $$

  WITH section_parts AS (
    SELECT * FROM questionnaire_parts_with_descendents(in_questionnaire_id)
    WHERE part_type = 'Section'
  )
  SELECT sections.*
  FROM section_parts
  JOIN sections ON sections.id = part_id
$$;


--
-- Name: resolve_dependent_sections_end(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION resolve_dependent_sections_end() RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  UPDATE sections
  SET depends_on_question_id = tmp_dependent_sections.depends_on_question_id,
  depends_on_option_id = tmp_dependent_sections.depends_on_option_id
  FROM tmp_dependent_sections
  WHERE tmp_dependent_sections.id = sections.id;
  DROP TABLE tmp_dependent_sections;
END;
$$;


--
-- Name: resolve_dependent_sections_start(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION resolve_dependent_sections_start() RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  CREATE TEMP TABLE tmp_dependent_sections AS
  SELECT tmp_sections.id AS id,
  tmp_questions.id AS depends_on_question_id,
  copied_multi_answer_options.id AS depends_on_option_id
  FROM tmp_sections
  JOIN tmp_questions
  ON tmp_questions.original_id = tmp_sections.depends_on_question_id
  JOIN (
    SELECT multi_answer_options.* FROM multi_answer_options
    JOIN tmp_multi_answers
    ON multi_answer_options.multi_answer_id = tmp_multi_answers.id
  ) copied_multi_answer_options
  ON copied_multi_answer_options.original_id = tmp_sections.depends_on_option_id;
  CREATE UNIQUE INDEX ON tmp_dependent_sections (id);
END;
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
    language character varying(255) NOT NULL,
    option_text text,
    multi_answer_option_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    is_default_language boolean DEFAULT false NOT NULL
);


--
-- Name: multi_answer_options; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: range_answer_option_fields; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: range_answer_options; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
        CASE
            WHEN ((ap.field_type_type)::text = 'MultiAnswerOption'::text) THEN mao.language
            WHEN ((ap.field_type_type)::text = 'RangeAnswerOption'::text) THEN rao.language
            ELSE ''::text
        END AS language,
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
-- Name: questionnaires; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
    display_in_tab_max_level character varying(255) DEFAULT 3,
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
    language character varying(255) NOT NULL,
    description text,
    section_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    is_default_language boolean DEFAULT false NOT NULL,
    tab_title text
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
-- Name: loop_item_name_fields; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: loop_item_names; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: loop_items; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
     LEFT JOIN mao_options ON (((mao_options.multi_answer_id = q.answer_type_id) AND (mao_options.language = q.language))))
     LEFT JOIN rao_options ON (((rao_options.range_answer_id = q.answer_type_id) AND (rao_options.language = q.language))));


--
-- Name: authorized_submitters; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
    logo_updated_at timestamp without time zone,
    sub_title character varying(255) DEFAULT ''::character varying
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
    loop_item_name_id integer NOT NULL,
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
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
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
-- Name: matrix_answer_option_fields; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: matrix_answer_column_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE matrix_answer_column_fields_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: matrix_answer_column_fields_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE matrix_answer_column_fields_id_seq OWNED BY matrix_answer_option_fields.id;


--
-- Name: matrix_answer_options; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE matrix_answer_options (
    id integer NOT NULL,
    matrix_answer_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    original_id integer
);


--
-- Name: matrix_answer_columns_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE matrix_answer_columns_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: matrix_answer_columns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE matrix_answer_columns_id_seq OWNED BY matrix_answer_options.id;


--
-- Name: matrix_answer_drop_option_fields; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
    matrix_answer_id integer NOT NULL,
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
-- Name: matrix_answer_queries; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE matrix_answer_queries (
    id integer NOT NULL,
    matrix_answer_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    original_id integer
);


--
-- Name: matrix_answer_query_fields; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: matrix_answer_row_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE matrix_answer_row_fields_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: matrix_answer_row_fields_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE matrix_answer_row_fields_id_seq OWNED BY matrix_answer_query_fields.id;


--
-- Name: matrix_answer_rows_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE matrix_answer_rows_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: matrix_answer_rows_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE matrix_answer_rows_id_seq OWNED BY matrix_answer_queries.id;


--
-- Name: matrix_answers; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
    question_id integer NOT NULL,
    extra_id integer NOT NULL,
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
    question_id integer NOT NULL,
    loop_item_type_id integer NOT NULL,
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
    rank_answer_id integer NOT NULL,
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
-- Name: report_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE report_fields_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: report_fields_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE report_fields_id_seq OWNED BY questionnaire_fields.id;


--
-- Name: reports_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE reports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE reports_id_seq OWNED BY questionnaires.id;


--
-- Name: roles; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE roles (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
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
    section_id integer NOT NULL,
    extra_id integer NOT NULL,
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
    name character varying(255) NOT NULL
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
    user_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    filtering_field_id integer NOT NULL,
    field_value character varying(255)
);


--
-- Name: user_section_submission_states; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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
-- Name: user_user_characteristic_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE user_user_characteristic_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_user_characteristic_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE user_user_characteristic_items_id_seq OWNED BY user_filtering_fields.id;


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

ALTER TABLE ONLY matrix_answer_option_fields ALTER COLUMN id SET DEFAULT nextval('matrix_answer_column_fields_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY matrix_answer_options ALTER COLUMN id SET DEFAULT nextval('matrix_answer_columns_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY matrix_answer_queries ALTER COLUMN id SET DEFAULT nextval('matrix_answer_rows_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY matrix_answer_query_fields ALTER COLUMN id SET DEFAULT nextval('matrix_answer_row_fields_id_seq'::regclass);


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

ALTER TABLE ONLY questionnaire_fields ALTER COLUMN id SET DEFAULT nextval('report_fields_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY questionnaire_parts ALTER COLUMN id SET DEFAULT nextval('questionnaire_parts_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY questionnaires ALTER COLUMN id SET DEFAULT nextval('reports_id_seq'::regclass);


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

ALTER TABLE ONLY user_filtering_fields ALTER COLUMN id SET DEFAULT nextval('user_user_characteristic_items_id_seq'::regclass);


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
-- Name: matrix_answer_column_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY matrix_answer_option_fields
    ADD CONSTRAINT matrix_answer_column_fields_pkey PRIMARY KEY (id);


--
-- Name: matrix_answer_columns_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY matrix_answer_options
    ADD CONSTRAINT matrix_answer_columns_pkey PRIMARY KEY (id);


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
-- Name: matrix_answer_row_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY matrix_answer_query_fields
    ADD CONSTRAINT matrix_answer_row_fields_pkey PRIMARY KEY (id);


--
-- Name: matrix_answer_rows_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY matrix_answer_queries
    ADD CONSTRAINT matrix_answer_rows_pkey PRIMARY KEY (id);


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
-- Name: questionnaire_parts_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY questionnaire_parts
    ADD CONSTRAINT questionnaire_parts_pkey PRIMARY KEY (id);


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
-- Name: report_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY questionnaire_fields
    ADD CONSTRAINT report_fields_pkey PRIMARY KEY (id);


--
-- Name: reports_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY questionnaires
    ADD CONSTRAINT reports_pkey PRIMARY KEY (id);


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
-- Name: user_section_submission_states_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_section_submission_states
    ADD CONSTRAINT user_section_submission_states_pkey PRIMARY KEY (id);


--
-- Name: user_user_characteristic_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_filtering_fields
    ADD CONSTRAINT user_user_characteristic_items_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_alerts_on_deadline_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_alerts_on_deadline_id ON alerts USING btree (deadline_id);


--
-- Name: index_alerts_on_reminder_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_alerts_on_reminder_id ON alerts USING btree (reminder_id);


--
-- Name: index_answer_links_on_answer_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_answer_links_on_answer_id ON answer_links USING btree (answer_id);


--
-- Name: index_answer_part_matrix_options_on_answer_part_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_answer_part_matrix_options_on_answer_part_id ON answer_part_matrix_options USING btree (answer_part_id);


--
-- Name: index_answer_part_matrix_options_on_drop_option_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_answer_part_matrix_options_on_drop_option_id ON answer_part_matrix_options USING btree (matrix_answer_drop_option_id);


--
-- Name: index_answer_part_matrix_options_on_matrix_answer_option_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_answer_part_matrix_options_on_matrix_answer_option_id ON answer_part_matrix_options USING btree (matrix_answer_option_id);


--
-- Name: index_answer_parts_on_answer_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_answer_parts_on_answer_id ON answer_parts USING btree (answer_id);


--
-- Name: index_answer_parts_on_field_type_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_answer_parts_on_field_type_id ON answer_parts USING btree (field_type_id);


--
-- Name: index_answers_on_last_editor_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_answers_on_last_editor_id ON answers USING btree (last_editor_id);


--
-- Name: index_answers_on_loop_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_answers_on_loop_item_id ON answers USING btree (loop_item_id);


--
-- Name: index_answers_on_question_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_answers_on_question_id ON answers USING btree (question_id);


--
-- Name: index_answers_on_question_id_and_user_id_and_looping_identifier; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_answers_on_question_id_and_user_id_and_looping_identifier ON answers USING btree (question_id, user_id, looping_identifier);


--
-- Name: index_answers_on_questionnaire_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_answers_on_questionnaire_id ON answers USING btree (questionnaire_id);


--
-- Name: index_answers_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_answers_on_user_id ON answers USING btree (user_id);


--
-- Name: index_assignments_on_role_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_assignments_on_role_id ON assignments USING btree (role_id);


--
-- Name: index_assignments_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_assignments_on_user_id ON assignments USING btree (user_id);


--
-- Name: index_authorized_submitters_on_questionnaire_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_authorized_submitters_on_questionnaire_id ON authorized_submitters USING btree (questionnaire_id);


--
-- Name: index_authorized_submitters_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_authorized_submitters_on_user_id ON authorized_submitters USING btree (user_id);


--
-- Name: index_deadlines_on_questionnaire_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_deadlines_on_questionnaire_id ON deadlines USING btree (questionnaire_id);


--
-- Name: index_delegate_text_answers_on_answer_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_delegate_text_answers_on_answer_id ON delegate_text_answers USING btree (answer_id);


--
-- Name: index_delegate_text_answers_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_delegate_text_answers_on_user_id ON delegate_text_answers USING btree (user_id);


--
-- Name: index_delegated_loop_item_names_on_delegation_section_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_delegated_loop_item_names_on_delegation_section_id ON delegated_loop_item_names USING btree (delegation_section_id);


--
-- Name: index_delegated_loop_item_names_on_loop_item_name_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_delegated_loop_item_names_on_loop_item_name_id ON delegated_loop_item_names USING btree (loop_item_name_id);


--
-- Name: index_delegation_sections_on_delegation_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_delegation_sections_on_delegation_id ON delegation_sections USING btree (delegation_id);


--
-- Name: index_delegation_sections_on_section_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_delegation_sections_on_section_id ON delegation_sections USING btree (section_id);


--
-- Name: index_documents_on_answer_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_documents_on_answer_id ON documents USING btree (answer_id);


--
-- Name: index_extras_on_loop_item_type_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_extras_on_loop_item_type_id ON extras USING btree (loop_item_type_id);


--
-- Name: index_filtering_fields_on_questionnaire_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_filtering_fields_on_questionnaire_id ON filtering_fields USING btree (questionnaire_id);


--
-- Name: index_item_extra_fields_on_item_extra_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_item_extra_fields_on_item_extra_id ON item_extra_fields USING btree (item_extra_id);


--
-- Name: index_item_extras_on_extra_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_item_extras_on_extra_id ON item_extras USING btree (extra_id);


--
-- Name: index_item_extras_on_loop_item_name_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_item_extras_on_loop_item_name_id ON item_extras USING btree (loop_item_name_id);


--
-- Name: index_loop_item_name_fields_on_loop_item_name_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_loop_item_name_fields_on_loop_item_name_id ON loop_item_name_fields USING btree (loop_item_name_id);


--
-- Name: index_loop_item_names_on_loop_item_type_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_loop_item_names_on_loop_item_type_id ON loop_item_names USING btree (loop_item_type_id);


--
-- Name: index_loop_item_names_on_loop_source_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_loop_item_names_on_loop_source_id ON loop_item_names USING btree (loop_source_id);


--
-- Name: index_loop_item_types_on_filtering_field_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_loop_item_types_on_filtering_field_id ON loop_item_types USING btree (filtering_field_id);


--
-- Name: index_loop_item_types_on_loop_source_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_loop_item_types_on_loop_source_id ON loop_item_types USING btree (loop_source_id);


--
-- Name: index_loop_item_types_on_parent_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_loop_item_types_on_parent_id ON loop_item_types USING btree (parent_id);


--
-- Name: index_loop_item_types_on_rgt; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_loop_item_types_on_rgt ON loop_item_types USING btree (rgt);


--
-- Name: index_loop_items_on_loop_item_name_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_loop_items_on_loop_item_name_id ON loop_items USING btree (loop_item_name_id);


--
-- Name: index_loop_items_on_loop_item_type_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_loop_items_on_loop_item_type_id ON loop_items USING btree (loop_item_type_id);


--
-- Name: index_loop_items_on_parent_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_loop_items_on_parent_id ON loop_items USING btree (parent_id);


--
-- Name: index_loop_items_on_rgt; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_loop_items_on_rgt ON loop_items USING btree (rgt);


--
-- Name: index_loop_sources_on_questionnaire_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_loop_sources_on_questionnaire_id ON loop_sources USING btree (questionnaire_id);


--
-- Name: index_matrix_answer_drop_option_fields_on_drop_option_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_matrix_answer_drop_option_fields_on_drop_option_id ON matrix_answer_drop_option_fields USING btree (matrix_answer_drop_option_id);


--
-- Name: index_matrix_answer_drop_options_on_matrix_answer_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_matrix_answer_drop_options_on_matrix_answer_id ON matrix_answer_drop_options USING btree (matrix_answer_id);


--
-- Name: index_matrix_answer_option_fields_on_matrix_answer_option_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_matrix_answer_option_fields_on_matrix_answer_option_id ON matrix_answer_option_fields USING btree (matrix_answer_option_id);


--
-- Name: index_matrix_answer_options_on_matrix_answer_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_matrix_answer_options_on_matrix_answer_id ON matrix_answer_options USING btree (matrix_answer_id);


--
-- Name: index_matrix_answer_queries_on_matrix_answer_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_matrix_answer_queries_on_matrix_answer_id ON matrix_answer_queries USING btree (matrix_answer_id);


--
-- Name: index_matrix_answer_query_fields_on_matrix_answer_query_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_matrix_answer_query_fields_on_matrix_answer_query_id ON matrix_answer_query_fields USING btree (matrix_answer_query_id);


--
-- Name: index_multi_answer_option_fields_on_language; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_multi_answer_option_fields_on_language ON multi_answer_option_fields USING btree (language);


--
-- Name: index_multi_answer_option_fields_on_multi_answer_option_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_multi_answer_option_fields_on_multi_answer_option_id ON multi_answer_option_fields USING btree (multi_answer_option_id);


--
-- Name: index_multi_answer_options_on_multi_answer_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_multi_answer_options_on_multi_answer_id ON multi_answer_options USING btree (multi_answer_id);


--
-- Name: index_other_fields_on_multi_answer_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_other_fields_on_multi_answer_id ON other_fields USING btree (multi_answer_id);


--
-- Name: index_pdf_files_on_questionnaire_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_pdf_files_on_questionnaire_id ON pdf_files USING btree (questionnaire_id);


--
-- Name: index_pdf_files_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_pdf_files_on_user_id ON pdf_files USING btree (user_id);


--
-- Name: index_persistent_errors_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_persistent_errors_on_user_id ON persistent_errors USING btree (user_id);


--
-- Name: index_question_extras_on_extra_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_question_extras_on_extra_id ON question_extras USING btree (extra_id);


--
-- Name: index_question_extras_on_question_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_question_extras_on_question_id ON question_extras USING btree (question_id);


--
-- Name: index_question_fields_on_question_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_question_fields_on_question_id ON question_fields USING btree (question_id);


--
-- Name: index_question_fields_on_question_id_and_language; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_question_fields_on_question_id_and_language ON question_fields USING btree (question_id, language);


--
-- Name: index_question_loop_types_on_loop_item_type_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_question_loop_types_on_loop_item_type_id ON question_loop_types USING btree (loop_item_type_id);


--
-- Name: index_question_loop_types_on_question_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_question_loop_types_on_question_id ON question_loop_types USING btree (question_id);


--
-- Name: index_questionnaire_fields_on_questionnaire_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_questionnaire_fields_on_questionnaire_id ON questionnaire_fields USING btree (questionnaire_id);


--
-- Name: index_questionnaire_parts_on_parent_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_questionnaire_parts_on_parent_id ON questionnaire_parts USING btree (parent_id);


--
-- Name: index_questionnaire_parts_on_questionnaire_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_questionnaire_parts_on_questionnaire_id ON questionnaire_parts USING btree (questionnaire_id);


--
-- Name: index_questionnaire_parts_on_rgt; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_questionnaire_parts_on_rgt ON questionnaire_parts USING btree (rgt);


--
-- Name: index_questionnaires_on_last_editor_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_questionnaires_on_last_editor_id ON questionnaires USING btree (last_editor_id);


--
-- Name: index_questionnaires_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_questionnaires_on_user_id ON questionnaires USING btree (user_id);


--
-- Name: index_questions_on_section_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_questions_on_section_id ON questions USING btree (section_id);


--
-- Name: index_range_answer_option_fields_on_range_answer_option_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_range_answer_option_fields_on_range_answer_option_id ON range_answer_option_fields USING btree (range_answer_option_id);


--
-- Name: index_range_answer_options_on_range_answer_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_range_answer_options_on_range_answer_id ON range_answer_options USING btree (range_answer_id);


--
-- Name: index_rank_answer_option_fields_on_rank_answer_option_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_rank_answer_option_fields_on_rank_answer_option_id ON rank_answer_option_fields USING btree (rank_answer_option_id);


--
-- Name: index_rank_answer_options_on_rank_answer_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_rank_answer_options_on_rank_answer_id ON rank_answer_options USING btree (rank_answer_id);


--
-- Name: index_section_extras_on_extra_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_section_extras_on_extra_id ON section_extras USING btree (extra_id);


--
-- Name: index_section_extras_on_section_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_section_extras_on_section_id ON section_extras USING btree (section_id);


--
-- Name: index_section_fields_on_section_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_section_fields_on_section_id ON section_fields USING btree (section_id);


--
-- Name: index_section_fields_on_section_id_and_language; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_section_fields_on_section_id_and_language ON section_fields USING btree (section_id, language);


--
-- Name: index_sections_on_depends_on_option_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_sections_on_depends_on_option_id ON sections USING btree (depends_on_option_id);


--
-- Name: index_sections_on_depends_on_question_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_sections_on_depends_on_question_id ON sections USING btree (depends_on_question_id);


--
-- Name: index_sections_on_loop_item_type_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_sections_on_loop_item_type_id ON sections USING btree (loop_item_type_id);


--
-- Name: index_sections_on_loop_source_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_sections_on_loop_source_id ON sections USING btree (loop_source_id);


--
-- Name: index_source_files_on_loop_source_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_source_files_on_loop_source_id ON source_files USING btree (loop_source_id);


--
-- Name: index_taggings_on_tag_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_taggings_on_tag_id ON taggings USING btree (tag_id);


--
-- Name: index_taggings_on_taggable_id_and_taggable_type_and_context; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_taggings_on_taggable_id_and_taggable_type_and_context ON taggings USING btree (taggable_id, taggable_type, context);


--
-- Name: index_text_answer_fields_on_text_answer_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_text_answer_fields_on_text_answer_id ON text_answer_fields USING btree (text_answer_id);


--
-- Name: index_user_delegates_on_delegate_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_delegates_on_delegate_id ON user_delegates USING btree (delegate_id);


--
-- Name: index_user_delegates_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_delegates_on_user_id ON user_delegates USING btree (user_id);


--
-- Name: index_user_filtering_fields_on_filtering_field_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_filtering_fields_on_filtering_field_id ON user_filtering_fields USING btree (filtering_field_id);


--
-- Name: index_user_filtering_fields_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_filtering_fields_on_user_id ON user_filtering_fields USING btree (user_id);


--
-- Name: index_user_section_submission_states_on_loop_item_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_section_submission_states_on_loop_item_id ON user_section_submission_states USING btree (loop_item_id);


--
-- Name: index_user_section_submission_states_on_section_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_section_submission_states_on_section_id ON user_section_submission_states USING btree (section_id);


--
-- Name: index_user_section_submission_states_on_user_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_user_section_submission_states_on_user_id ON user_section_submission_states USING btree (user_id);


--
-- Name: index_users_on_creator_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_users_on_creator_id ON users USING btree (creator_id);


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
-- Name: answer_links_answer_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY answer_links
    ADD CONSTRAINT answer_links_answer_id_fk FOREIGN KEY (answer_id) REFERENCES answers(id) ON DELETE CASCADE;


--
-- Name: answer_part_matrix_options_answer_part_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY answer_part_matrix_options
    ADD CONSTRAINT answer_part_matrix_options_answer_part_id_fk FOREIGN KEY (answer_part_id) REFERENCES answer_parts(id) ON DELETE CASCADE;


--
-- Name: answer_part_matrix_options_drop_option_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY answer_part_matrix_options
    ADD CONSTRAINT answer_part_matrix_options_drop_option_id_fk FOREIGN KEY (matrix_answer_drop_option_id) REFERENCES matrix_answer_drop_options(id) ON DELETE CASCADE;


--
-- Name: answer_part_matrix_options_option_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY answer_part_matrix_options
    ADD CONSTRAINT answer_part_matrix_options_option_id_fk FOREIGN KEY (matrix_answer_option_id) REFERENCES matrix_answer_options(id) ON DELETE CASCADE;


--
-- Name: answer_parts_answer_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY answer_parts
    ADD CONSTRAINT answer_parts_answer_id_fk FOREIGN KEY (answer_id) REFERENCES answers(id) ON DELETE CASCADE;


--
-- Name: answer_parts_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY answer_parts
    ADD CONSTRAINT answer_parts_original_id_fk FOREIGN KEY (original_id) REFERENCES answer_parts(id) ON DELETE SET NULL;


--
-- Name: answers_last_editor_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY answers
    ADD CONSTRAINT answers_last_editor_id_fk FOREIGN KEY (last_editor_id) REFERENCES users(id) ON DELETE SET NULL;


--
-- Name: answers_loop_item_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY answers
    ADD CONSTRAINT answers_loop_item_id_fk FOREIGN KEY (loop_item_id) REFERENCES loop_items(id) ON DELETE CASCADE;


--
-- Name: answers_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY answers
    ADD CONSTRAINT answers_original_id_fk FOREIGN KEY (original_id) REFERENCES answers(id);


--
-- Name: answers_question_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY answers
    ADD CONSTRAINT answers_question_id_fk FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE;


--
-- Name: answers_questionnaire_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY answers
    ADD CONSTRAINT answers_questionnaire_id_fk FOREIGN KEY (questionnaire_id) REFERENCES questionnaires(id) ON DELETE CASCADE;


--
-- Name: answers_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY answers
    ADD CONSTRAINT answers_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: assignments_role_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY assignments
    ADD CONSTRAINT assignments_role_id_fk FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE;


--
-- Name: assignments_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY assignments
    ADD CONSTRAINT assignments_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: authorized_submitters_questionnaire_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY authorized_submitters
    ADD CONSTRAINT authorized_submitters_questionnaire_id_fk FOREIGN KEY (questionnaire_id) REFERENCES questionnaires(id) ON DELETE CASCADE;


--
-- Name: authorized_submitters_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY authorized_submitters
    ADD CONSTRAINT authorized_submitters_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


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
-- Name: delegated_loop_item_names_delegation_section_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY delegated_loop_item_names
    ADD CONSTRAINT delegated_loop_item_names_delegation_section_id_fk FOREIGN KEY (delegation_section_id) REFERENCES delegation_sections(id) ON DELETE CASCADE;


--
-- Name: delegated_loop_item_names_loop_item_name_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY delegated_loop_item_names
    ADD CONSTRAINT delegated_loop_item_names_loop_item_name_id_fk FOREIGN KEY (loop_item_name_id) REFERENCES loop_item_names(id) ON DELETE CASCADE;


--
-- Name: delegation_sections_delegation_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY delegation_sections
    ADD CONSTRAINT delegation_sections_delegation_id_fk FOREIGN KEY (delegation_id) REFERENCES delegations(id) ON DELETE CASCADE;


--
-- Name: delegation_sections_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY delegation_sections
    ADD CONSTRAINT delegation_sections_original_id_fk FOREIGN KEY (original_id) REFERENCES delegation_sections(id) ON DELETE SET NULL;


--
-- Name: delegation_sections_section_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY delegation_sections
    ADD CONSTRAINT delegation_sections_section_id_fk FOREIGN KEY (section_id) REFERENCES sections(id) ON DELETE CASCADE;


--
-- Name: delegations_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY delegations
    ADD CONSTRAINT delegations_original_id_fk FOREIGN KEY (original_id) REFERENCES delegations(id) ON DELETE SET NULL;


--
-- Name: documents_answer_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY documents
    ADD CONSTRAINT documents_answer_id_fk FOREIGN KEY (answer_id) REFERENCES answers(id) ON DELETE CASCADE;


--
-- Name: documents_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY documents
    ADD CONSTRAINT documents_original_id_fk FOREIGN KEY (original_id) REFERENCES documents(id) ON DELETE SET NULL;


--
-- Name: extras_loop_item_type_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY extras
    ADD CONSTRAINT extras_loop_item_type_id_fk FOREIGN KEY (loop_item_type_id) REFERENCES loop_item_types(id) ON DELETE CASCADE;


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
-- Name: filtering_fields_questionnaire_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY filtering_fields
    ADD CONSTRAINT filtering_fields_questionnaire_id_fk FOREIGN KEY (questionnaire_id) REFERENCES questionnaires(id) ON DELETE CASCADE;


--
-- Name: item_extra_fields_item_extra_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY item_extra_fields
    ADD CONSTRAINT item_extra_fields_item_extra_id_fk FOREIGN KEY (item_extra_id) REFERENCES item_extras(id) ON DELETE CASCADE;


--
-- Name: item_extras_extra_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY item_extras
    ADD CONSTRAINT item_extras_extra_id_fk FOREIGN KEY (extra_id) REFERENCES extras(id) ON DELETE CASCADE;


--
-- Name: item_extras_loop_item_name_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY item_extras
    ADD CONSTRAINT item_extras_loop_item_name_id_fk FOREIGN KEY (loop_item_name_id) REFERENCES loop_item_names(id) ON DELETE CASCADE;


--
-- Name: item_extras_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY item_extras
    ADD CONSTRAINT item_extras_original_id_fk FOREIGN KEY (original_id) REFERENCES item_extras(id) ON DELETE SET NULL;


--
-- Name: loop_item_name_fields_loop_item_name_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY loop_item_name_fields
    ADD CONSTRAINT loop_item_name_fields_loop_item_name_id_fk FOREIGN KEY (loop_item_name_id) REFERENCES loop_item_names(id) ON DELETE CASCADE;


--
-- Name: loop_item_names_loop_item_type_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY loop_item_names
    ADD CONSTRAINT loop_item_names_loop_item_type_id_fk FOREIGN KEY (loop_item_type_id) REFERENCES loop_item_types(id) ON DELETE CASCADE;


--
-- Name: loop_item_names_loop_source_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY loop_item_names
    ADD CONSTRAINT loop_item_names_loop_source_id_fk FOREIGN KEY (loop_source_id) REFERENCES loop_sources(id) ON DELETE CASCADE;


--
-- Name: loop_item_names_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY loop_item_names
    ADD CONSTRAINT loop_item_names_original_id_fk FOREIGN KEY (original_id) REFERENCES loop_item_names(id) ON DELETE SET NULL;


--
-- Name: loop_item_types_filtering_field_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY loop_item_types
    ADD CONSTRAINT loop_item_types_filtering_field_id_fk FOREIGN KEY (filtering_field_id) REFERENCES filtering_fields(id) ON DELETE SET NULL;


--
-- Name: loop_item_types_loop_source_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY loop_item_types
    ADD CONSTRAINT loop_item_types_loop_source_id_fk FOREIGN KEY (loop_source_id) REFERENCES loop_sources(id) ON DELETE CASCADE;


--
-- Name: loop_item_types_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY loop_item_types
    ADD CONSTRAINT loop_item_types_original_id_fk FOREIGN KEY (original_id) REFERENCES loop_item_types(id) ON DELETE SET NULL;


--
-- Name: loop_item_types_parent_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY loop_item_types
    ADD CONSTRAINT loop_item_types_parent_id_fk FOREIGN KEY (parent_id) REFERENCES loop_item_types(id) ON DELETE CASCADE;


--
-- Name: loop_items_loop_item_name_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY loop_items
    ADD CONSTRAINT loop_items_loop_item_name_id_fk FOREIGN KEY (loop_item_name_id) REFERENCES loop_item_names(id) ON DELETE CASCADE;


--
-- Name: loop_items_loop_item_type_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY loop_items
    ADD CONSTRAINT loop_items_loop_item_type_id_fk FOREIGN KEY (loop_item_type_id) REFERENCES loop_item_types(id) ON DELETE CASCADE;


--
-- Name: loop_items_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY loop_items
    ADD CONSTRAINT loop_items_original_id_fk FOREIGN KEY (original_id) REFERENCES loop_items(id) ON DELETE SET NULL;


--
-- Name: loop_items_parent_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY loop_items
    ADD CONSTRAINT loop_items_parent_id_fk FOREIGN KEY (parent_id) REFERENCES loop_items(id) ON DELETE CASCADE;


--
-- Name: loop_sources_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY loop_sources
    ADD CONSTRAINT loop_sources_original_id_fk FOREIGN KEY (original_id) REFERENCES loop_sources(id) ON DELETE SET NULL;


--
-- Name: loop_sources_questionnaire_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY loop_sources
    ADD CONSTRAINT loop_sources_questionnaire_id_fk FOREIGN KEY (questionnaire_id) REFERENCES questionnaires(id) ON DELETE CASCADE;


--
-- Name: matrix_answer_drop_option_fields_drop_option_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY matrix_answer_drop_option_fields
    ADD CONSTRAINT matrix_answer_drop_option_fields_drop_option_id_fk FOREIGN KEY (matrix_answer_drop_option_id) REFERENCES matrix_answer_drop_options(id) ON DELETE CASCADE;


--
-- Name: matrix_answer_drop_options_matrix_answer_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY matrix_answer_drop_options
    ADD CONSTRAINT matrix_answer_drop_options_matrix_answer_id_fk FOREIGN KEY (matrix_answer_id) REFERENCES matrix_answers(id) ON DELETE CASCADE;


--
-- Name: matrix_answer_drop_options_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY matrix_answer_drop_options
    ADD CONSTRAINT matrix_answer_drop_options_original_id_fk FOREIGN KEY (original_id) REFERENCES matrix_answer_drop_options(id) ON DELETE SET NULL;


--
-- Name: matrix_answer_option_fields_option_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY matrix_answer_option_fields
    ADD CONSTRAINT matrix_answer_option_fields_option_id_fk FOREIGN KEY (matrix_answer_option_id) REFERENCES matrix_answer_options(id) ON DELETE CASCADE;


--
-- Name: matrix_answer_options_matrix_answer_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY matrix_answer_options
    ADD CONSTRAINT matrix_answer_options_matrix_answer_id_fk FOREIGN KEY (matrix_answer_id) REFERENCES matrix_answers(id) ON DELETE CASCADE;


--
-- Name: matrix_answer_options_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY matrix_answer_options
    ADD CONSTRAINT matrix_answer_options_original_id_fk FOREIGN KEY (original_id) REFERENCES matrix_answer_options(id) ON DELETE SET NULL;


--
-- Name: matrix_answer_queries_matrix_answer_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY matrix_answer_queries
    ADD CONSTRAINT matrix_answer_queries_matrix_answer_id_fk FOREIGN KEY (matrix_answer_id) REFERENCES matrix_answers(id) ON DELETE CASCADE;


--
-- Name: matrix_answer_queries_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY matrix_answer_queries
    ADD CONSTRAINT matrix_answer_queries_original_id_fk FOREIGN KEY (original_id) REFERENCES matrix_answer_queries(id) ON DELETE SET NULL;


--
-- Name: matrix_answer_query_fields_query_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY matrix_answer_query_fields
    ADD CONSTRAINT matrix_answer_query_fields_query_id_fk FOREIGN KEY (matrix_answer_query_id) REFERENCES matrix_answer_queries(id) ON DELETE CASCADE;


--
-- Name: matrix_answers_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY matrix_answers
    ADD CONSTRAINT matrix_answers_original_id_fk FOREIGN KEY (original_id) REFERENCES matrix_answers(id) ON DELETE SET NULL;


--
-- Name: multi_answer_option_fields_multi_answer_option_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY multi_answer_option_fields
    ADD CONSTRAINT multi_answer_option_fields_multi_answer_option_id_fk FOREIGN KEY (multi_answer_option_id) REFERENCES multi_answer_options(id) ON DELETE CASCADE;


--
-- Name: multi_answer_options_multi_answer_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY multi_answer_options
    ADD CONSTRAINT multi_answer_options_multi_answer_id_fk FOREIGN KEY (multi_answer_id) REFERENCES multi_answers(id) ON DELETE CASCADE;


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
-- Name: other_fields_multi_answer_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY other_fields
    ADD CONSTRAINT other_fields_multi_answer_id_fk FOREIGN KEY (multi_answer_id) REFERENCES multi_answers(id) ON DELETE CASCADE;


--
-- Name: pdf_files_questionnaire_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY pdf_files
    ADD CONSTRAINT pdf_files_questionnaire_id_fk FOREIGN KEY (questionnaire_id) REFERENCES questionnaires(id) ON DELETE CASCADE;


--
-- Name: pdf_files_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY pdf_files
    ADD CONSTRAINT pdf_files_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: persistent_errors_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY persistent_errors
    ADD CONSTRAINT persistent_errors_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: question_extras_extra_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY question_extras
    ADD CONSTRAINT question_extras_extra_id_fk FOREIGN KEY (extra_id) REFERENCES extras(id) ON DELETE CASCADE;


--
-- Name: question_extras_question_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY question_extras
    ADD CONSTRAINT question_extras_question_id_fk FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE;


--
-- Name: question_fields_question_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY question_fields
    ADD CONSTRAINT question_fields_question_id_fk FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE;


--
-- Name: question_loop_types_loop_item_type_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY question_loop_types
    ADD CONSTRAINT question_loop_types_loop_item_type_id_fk FOREIGN KEY (loop_item_type_id) REFERENCES loop_item_types(id) ON DELETE CASCADE;


--
-- Name: question_loop_types_question_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY question_loop_types
    ADD CONSTRAINT question_loop_types_question_id_fk FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE;


--
-- Name: questionnaire_fields_questionnaire_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY questionnaire_fields
    ADD CONSTRAINT questionnaire_fields_questionnaire_id_fk FOREIGN KEY (questionnaire_id) REFERENCES questionnaires(id) ON DELETE CASCADE;


--
-- Name: questionnaire_parts_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY questionnaire_parts
    ADD CONSTRAINT questionnaire_parts_original_id_fk FOREIGN KEY (original_id) REFERENCES questionnaire_parts(id) ON DELETE SET NULL;


--
-- Name: questionnaire_parts_parent_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY questionnaire_parts
    ADD CONSTRAINT questionnaire_parts_parent_id_fk FOREIGN KEY (parent_id) REFERENCES questionnaire_parts(id) ON DELETE CASCADE;


--
-- Name: questionnaire_parts_questionnaire_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY questionnaire_parts
    ADD CONSTRAINT questionnaire_parts_questionnaire_id_fk FOREIGN KEY (questionnaire_id) REFERENCES questionnaires(id) ON DELETE CASCADE;


--
-- Name: questionnaires_last_editor_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY questionnaires
    ADD CONSTRAINT questionnaires_last_editor_id_fk FOREIGN KEY (last_editor_id) REFERENCES users(id) ON DELETE SET NULL;


--
-- Name: questionnaires_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY questionnaires
    ADD CONSTRAINT questionnaires_original_id_fk FOREIGN KEY (original_id) REFERENCES questionnaires(id) ON DELETE SET NULL;


--
-- Name: questionnaires_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY questionnaires
    ADD CONSTRAINT questionnaires_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE RESTRICT;


--
-- Name: questions_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY questions
    ADD CONSTRAINT questions_original_id_fk FOREIGN KEY (original_id) REFERENCES questions(id) ON DELETE SET NULL;


--
-- Name: questions_section_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY questions
    ADD CONSTRAINT questions_section_id_fk FOREIGN KEY (section_id) REFERENCES sections(id) ON DELETE CASCADE;


--
-- Name: range_answer_option_fields_range_answer_option_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY range_answer_option_fields
    ADD CONSTRAINT range_answer_option_fields_range_answer_option_id_fk FOREIGN KEY (range_answer_option_id) REFERENCES range_answer_options(id) ON DELETE CASCADE;


--
-- Name: range_answer_options_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY range_answer_options
    ADD CONSTRAINT range_answer_options_original_id_fk FOREIGN KEY (original_id) REFERENCES range_answer_options(id) ON DELETE SET NULL;


--
-- Name: range_answer_options_range_answer_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY range_answer_options
    ADD CONSTRAINT range_answer_options_range_answer_id_fk FOREIGN KEY (range_answer_id) REFERENCES range_answers(id) ON DELETE CASCADE;


--
-- Name: range_answers_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY range_answers
    ADD CONSTRAINT range_answers_original_id_fk FOREIGN KEY (original_id) REFERENCES range_answers(id) ON DELETE SET NULL;


--
-- Name: rank_answer_option_fields_rank_answer_option_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rank_answer_option_fields
    ADD CONSTRAINT rank_answer_option_fields_rank_answer_option_id_fk FOREIGN KEY (rank_answer_option_id) REFERENCES rank_answer_options(id) ON DELETE CASCADE;


--
-- Name: rank_answer_options_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rank_answer_options
    ADD CONSTRAINT rank_answer_options_original_id_fk FOREIGN KEY (original_id) REFERENCES rank_answer_options(id) ON DELETE SET NULL;


--
-- Name: rank_answer_options_rank_answer_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rank_answer_options
    ADD CONSTRAINT rank_answer_options_rank_answer_id_fk FOREIGN KEY (rank_answer_id) REFERENCES rank_answers(id) ON DELETE CASCADE;


--
-- Name: rank_answers_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY rank_answers
    ADD CONSTRAINT rank_answers_original_id_fk FOREIGN KEY (original_id) REFERENCES rank_answers(id) ON DELETE SET NULL;


--
-- Name: section_extras_extra_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY section_extras
    ADD CONSTRAINT section_extras_extra_id_fk FOREIGN KEY (extra_id) REFERENCES extras(id) ON DELETE CASCADE;


--
-- Name: section_extras_section_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY section_extras
    ADD CONSTRAINT section_extras_section_id_fk FOREIGN KEY (section_id) REFERENCES sections(id) ON DELETE CASCADE;


--
-- Name: section_fields_section_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY section_fields
    ADD CONSTRAINT section_fields_section_id_fk FOREIGN KEY (section_id) REFERENCES sections(id) ON DELETE CASCADE;


--
-- Name: sections_depends_on_option_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sections
    ADD CONSTRAINT sections_depends_on_option_id_fk FOREIGN KEY (depends_on_option_id) REFERENCES multi_answer_options(id) ON DELETE SET NULL;


--
-- Name: sections_depends_on_question_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sections
    ADD CONSTRAINT sections_depends_on_question_id_fk FOREIGN KEY (depends_on_question_id) REFERENCES questions(id) ON DELETE SET NULL;


--
-- Name: sections_loop_item_type_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sections
    ADD CONSTRAINT sections_loop_item_type_id_fk FOREIGN KEY (loop_item_type_id) REFERENCES loop_item_types(id) ON DELETE SET NULL;


--
-- Name: sections_loop_source_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sections
    ADD CONSTRAINT sections_loop_source_id_fk FOREIGN KEY (loop_source_id) REFERENCES loop_sources(id) ON DELETE SET NULL;


--
-- Name: sections_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY sections
    ADD CONSTRAINT sections_original_id_fk FOREIGN KEY (original_id) REFERENCES sections(id) ON DELETE SET NULL;


--
-- Name: source_files_loop_source_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY source_files
    ADD CONSTRAINT source_files_loop_source_id_fk FOREIGN KEY (loop_source_id) REFERENCES loop_sources(id) ON DELETE CASCADE;


--
-- Name: taggings_tag_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY taggings
    ADD CONSTRAINT taggings_tag_id_fk FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE;


--
-- Name: text_answer_fields_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY text_answer_fields
    ADD CONSTRAINT text_answer_fields_original_id_fk FOREIGN KEY (original_id) REFERENCES text_answer_fields(id) ON DELETE SET NULL;


--
-- Name: text_answer_fields_text_answer_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY text_answer_fields
    ADD CONSTRAINT text_answer_fields_text_answer_id_fk FOREIGN KEY (text_answer_id) REFERENCES text_answers(id) ON DELETE CASCADE;


--
-- Name: text_answers_original_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY text_answers
    ADD CONSTRAINT text_answers_original_id_fk FOREIGN KEY (original_id) REFERENCES text_answers(id) ON DELETE SET NULL;


--
-- Name: user_delegates_delegate_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_delegates
    ADD CONSTRAINT user_delegates_delegate_id_fk FOREIGN KEY (delegate_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: user_delegates_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_delegates
    ADD CONSTRAINT user_delegates_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: user_filtering_fields_filtering_field_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_filtering_fields
    ADD CONSTRAINT user_filtering_fields_filtering_field_id_fk FOREIGN KEY (filtering_field_id) REFERENCES filtering_fields(id) ON DELETE CASCADE;


--
-- Name: user_filtering_fields_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_filtering_fields
    ADD CONSTRAINT user_filtering_fields_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- Name: user_section_submission_states_loop_item_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_section_submission_states
    ADD CONSTRAINT user_section_submission_states_loop_item_id_fk FOREIGN KEY (loop_item_id) REFERENCES loop_items(id) ON DELETE CASCADE;


--
-- Name: user_section_submission_states_section_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_section_submission_states
    ADD CONSTRAINT user_section_submission_states_section_id_fk FOREIGN KEY (section_id) REFERENCES sections(id) ON DELETE CASCADE;


--
-- Name: user_section_submission_states_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY user_section_submission_states
    ADD CONSTRAINT user_section_submission_states_user_id_fk FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20091216144240');

INSERT INTO schema_migrations (version) VALUES ('20091216144402');

INSERT INTO schema_migrations (version) VALUES ('20091216144524');

INSERT INTO schema_migrations (version) VALUES ('20091222095411');

INSERT INTO schema_migrations (version) VALUES ('20091222103517');

INSERT INTO schema_migrations (version) VALUES ('20091222113533');

INSERT INTO schema_migrations (version) VALUES ('20091222120007');

INSERT INTO schema_migrations (version) VALUES ('20100104112543');

INSERT INTO schema_migrations (version) VALUES ('20100104112938');

INSERT INTO schema_migrations (version) VALUES ('20100104113218');

INSERT INTO schema_migrations (version) VALUES ('20100104113347');

INSERT INTO schema_migrations (version) VALUES ('20100115111120');

INSERT INTO schema_migrations (version) VALUES ('20100115120146');

INSERT INTO schema_migrations (version) VALUES ('20100119115933');

INSERT INTO schema_migrations (version) VALUES ('20100201114144');

INSERT INTO schema_migrations (version) VALUES ('20100201114344');

INSERT INTO schema_migrations (version) VALUES ('20100205160659');

INSERT INTO schema_migrations (version) VALUES ('20100209140108');

INSERT INTO schema_migrations (version) VALUES ('20100209140354');

INSERT INTO schema_migrations (version) VALUES ('20100209160251');

INSERT INTO schema_migrations (version) VALUES ('20100211140602');

INSERT INTO schema_migrations (version) VALUES ('20100211145413');

INSERT INTO schema_migrations (version) VALUES ('20100211145520');

INSERT INTO schema_migrations (version) VALUES ('20100211145830');

INSERT INTO schema_migrations (version) VALUES ('20100215120114');

INSERT INTO schema_migrations (version) VALUES ('20100215121456');

INSERT INTO schema_migrations (version) VALUES ('20100215121858');

INSERT INTO schema_migrations (version) VALUES ('20100215121956');

INSERT INTO schema_migrations (version) VALUES ('20100215133753');

INSERT INTO schema_migrations (version) VALUES ('20100215133945');

INSERT INTO schema_migrations (version) VALUES ('20100216143218');

INSERT INTO schema_migrations (version) VALUES ('20100219154557');

INSERT INTO schema_migrations (version) VALUES ('20100219154943');

INSERT INTO schema_migrations (version) VALUES ('20100223133152');

INSERT INTO schema_migrations (version) VALUES ('20100223133640');

INSERT INTO schema_migrations (version) VALUES ('20100224165830');

INSERT INTO schema_migrations (version) VALUES ('20100224172312');

INSERT INTO schema_migrations (version) VALUES ('20100226141323');

INSERT INTO schema_migrations (version) VALUES ('20100301161929');

INSERT INTO schema_migrations (version) VALUES ('20100302164229');

INSERT INTO schema_migrations (version) VALUES ('20100303162825');

INSERT INTO schema_migrations (version) VALUES ('20100311110216');

INSERT INTO schema_migrations (version) VALUES ('20100312102233');

INSERT INTO schema_migrations (version) VALUES ('20100315164848');

INSERT INTO schema_migrations (version) VALUES ('20100315165036');

INSERT INTO schema_migrations (version) VALUES ('20100318171938');

INSERT INTO schema_migrations (version) VALUES ('20100322144930');

INSERT INTO schema_migrations (version) VALUES ('20100324103935');

INSERT INTO schema_migrations (version) VALUES ('20100325094844');

INSERT INTO schema_migrations (version) VALUES ('20100326135435');

INSERT INTO schema_migrations (version) VALUES ('20100326145544');

INSERT INTO schema_migrations (version) VALUES ('20100326165258');

INSERT INTO schema_migrations (version) VALUES ('20100329104409');

INSERT INTO schema_migrations (version) VALUES ('20100330104949');

INSERT INTO schema_migrations (version) VALUES ('20100331110046');

INSERT INTO schema_migrations (version) VALUES ('20100331125616');

INSERT INTO schema_migrations (version) VALUES ('20100401123407');

INSERT INTO schema_migrations (version) VALUES ('20100401141952');

INSERT INTO schema_migrations (version) VALUES ('20100401144211');

INSERT INTO schema_migrations (version) VALUES ('20100415170751');

INSERT INTO schema_migrations (version) VALUES ('20100416125531');

INSERT INTO schema_migrations (version) VALUES ('20100416154208');

INSERT INTO schema_migrations (version) VALUES ('20100416154452');

INSERT INTO schema_migrations (version) VALUES ('20100416155223');

INSERT INTO schema_migrations (version) VALUES ('20100416155613');

INSERT INTO schema_migrations (version) VALUES ('20100416160303');

INSERT INTO schema_migrations (version) VALUES ('20100419143617');

INSERT INTO schema_migrations (version) VALUES ('20100420132443');

INSERT INTO schema_migrations (version) VALUES ('20100420163657');

INSERT INTO schema_migrations (version) VALUES ('20100420164759');

INSERT INTO schema_migrations (version) VALUES ('20100421140847');

INSERT INTO schema_migrations (version) VALUES ('20100422135900');

INSERT INTO schema_migrations (version) VALUES ('20100422142031');

INSERT INTO schema_migrations (version) VALUES ('20100422142208');

INSERT INTO schema_migrations (version) VALUES ('20100422182458');

INSERT INTO schema_migrations (version) VALUES ('20100423085339');

INSERT INTO schema_migrations (version) VALUES ('20100426092545');

INSERT INTO schema_migrations (version) VALUES ('20100426101145');

INSERT INTO schema_migrations (version) VALUES ('20100426101739');

INSERT INTO schema_migrations (version) VALUES ('20100427093144');

INSERT INTO schema_migrations (version) VALUES ('20100427100139');

INSERT INTO schema_migrations (version) VALUES ('20100427120953');

INSERT INTO schema_migrations (version) VALUES ('20100427140847');

INSERT INTO schema_migrations (version) VALUES ('20100428091102');

INSERT INTO schema_migrations (version) VALUES ('20100428095425');

INSERT INTO schema_migrations (version) VALUES ('20100429151708');

INSERT INTO schema_migrations (version) VALUES ('20100429170035');

INSERT INTO schema_migrations (version) VALUES ('20100505130819');

INSERT INTO schema_migrations (version) VALUES ('20100511164615');

INSERT INTO schema_migrations (version) VALUES ('20100511164913');

INSERT INTO schema_migrations (version) VALUES ('20100512092930');

INSERT INTO schema_migrations (version) VALUES ('20100512095121');

INSERT INTO schema_migrations (version) VALUES ('20100512102616');

INSERT INTO schema_migrations (version) VALUES ('20100513082553');

INSERT INTO schema_migrations (version) VALUES ('20100513083252');

INSERT INTO schema_migrations (version) VALUES ('20100514105446');

INSERT INTO schema_migrations (version) VALUES ('20100517160925');

INSERT INTO schema_migrations (version) VALUES ('20100518161109');

INSERT INTO schema_migrations (version) VALUES ('20100524112251');

INSERT INTO schema_migrations (version) VALUES ('20100524152242');

INSERT INTO schema_migrations (version) VALUES ('20100526132834');

INSERT INTO schema_migrations (version) VALUES ('20100527094259');

INSERT INTO schema_migrations (version) VALUES ('20100527095733');

INSERT INTO schema_migrations (version) VALUES ('20100527173427');

INSERT INTO schema_migrations (version) VALUES ('20100527173812');

INSERT INTO schema_migrations (version) VALUES ('20100527174001');

INSERT INTO schema_migrations (version) VALUES ('20100527174201');

INSERT INTO schema_migrations (version) VALUES ('20100528145112');

INSERT INTO schema_migrations (version) VALUES ('20100601082947');

INSERT INTO schema_migrations (version) VALUES ('20100601083339');

INSERT INTO schema_migrations (version) VALUES ('20100602141114');

INSERT INTO schema_migrations (version) VALUES ('20100604085246');

INSERT INTO schema_migrations (version) VALUES ('20100604112256');

INSERT INTO schema_migrations (version) VALUES ('20100712140227');

INSERT INTO schema_migrations (version) VALUES ('20100712140809');

INSERT INTO schema_migrations (version) VALUES ('20100713105341');

INSERT INTO schema_migrations (version) VALUES ('20100714105006');

INSERT INTO schema_migrations (version) VALUES ('20100719144332');

INSERT INTO schema_migrations (version) VALUES ('20100720085022');

INSERT INTO schema_migrations (version) VALUES ('20100720111356');

INSERT INTO schema_migrations (version) VALUES ('20100726082933');

INSERT INTO schema_migrations (version) VALUES ('20100726161853');

INSERT INTO schema_migrations (version) VALUES ('20100726163827');

INSERT INTO schema_migrations (version) VALUES ('20100727154002');

INSERT INTO schema_migrations (version) VALUES ('20100727155257');

INSERT INTO schema_migrations (version) VALUES ('20100727155513');

INSERT INTO schema_migrations (version) VALUES ('20100728144512');

INSERT INTO schema_migrations (version) VALUES ('20100728150553');

INSERT INTO schema_migrations (version) VALUES ('20100728150715');

INSERT INTO schema_migrations (version) VALUES ('20100803145618');

INSERT INTO schema_migrations (version) VALUES ('20100803161914');

INSERT INTO schema_migrations (version) VALUES ('20100804093414');

INSERT INTO schema_migrations (version) VALUES ('20100806085832');

INSERT INTO schema_migrations (version) VALUES ('20100806093819');

INSERT INTO schema_migrations (version) VALUES ('20100806094510');

INSERT INTO schema_migrations (version) VALUES ('20100806095439');

INSERT INTO schema_migrations (version) VALUES ('20100806101543');

INSERT INTO schema_migrations (version) VALUES ('20100806142439');

INSERT INTO schema_migrations (version) VALUES ('20100902101424');

INSERT INTO schema_migrations (version) VALUES ('20100902105340');

INSERT INTO schema_migrations (version) VALUES ('20100902110423');

INSERT INTO schema_migrations (version) VALUES ('20100909104358');

INSERT INTO schema_migrations (version) VALUES ('20100910075840');

INSERT INTO schema_migrations (version) VALUES ('20100914103345');

INSERT INTO schema_migrations (version) VALUES ('20100914103555');

INSERT INTO schema_migrations (version) VALUES ('20100914160219');

INSERT INTO schema_migrations (version) VALUES ('20100914161105');

INSERT INTO schema_migrations (version) VALUES ('20100915090421');

INSERT INTO schema_migrations (version) VALUES ('20100915093550');

INSERT INTO schema_migrations (version) VALUES ('20100916111650');

INSERT INTO schema_migrations (version) VALUES ('20100917085804');

INSERT INTO schema_migrations (version) VALUES ('20100921113333');

INSERT INTO schema_migrations (version) VALUES ('20100921155104');

INSERT INTO schema_migrations (version) VALUES ('20100922103307');

INSERT INTO schema_migrations (version) VALUES ('20100923093050');

INSERT INTO schema_migrations (version) VALUES ('20100923110454');

INSERT INTO schema_migrations (version) VALUES ('20100923140846');

INSERT INTO schema_migrations (version) VALUES ('20100923140909');

INSERT INTO schema_migrations (version) VALUES ('20100923140951');

INSERT INTO schema_migrations (version) VALUES ('20100923141655');

INSERT INTO schema_migrations (version) VALUES ('20100927140118');

INSERT INTO schema_migrations (version) VALUES ('20100929092844');

INSERT INTO schema_migrations (version) VALUES ('20100929101351');

INSERT INTO schema_migrations (version) VALUES ('20100929101405');

INSERT INTO schema_migrations (version) VALUES ('20100930085508');

INSERT INTO schema_migrations (version) VALUES ('20101004144844');

INSERT INTO schema_migrations (version) VALUES ('20101004165635');

INSERT INTO schema_migrations (version) VALUES ('20101004165709');

INSERT INTO schema_migrations (version) VALUES ('20101004165739');

INSERT INTO schema_migrations (version) VALUES ('20101004165813');

INSERT INTO schema_migrations (version) VALUES ('20101005094213');

INSERT INTO schema_migrations (version) VALUES ('20101005094821');

INSERT INTO schema_migrations (version) VALUES ('20101005095212');

INSERT INTO schema_migrations (version) VALUES ('20101005100721');

INSERT INTO schema_migrations (version) VALUES ('20101007111558');

INSERT INTO schema_migrations (version) VALUES ('20101012092449');

INSERT INTO schema_migrations (version) VALUES ('20101012122314');

INSERT INTO schema_migrations (version) VALUES ('20101013160101');

INSERT INTO schema_migrations (version) VALUES ('20101013160216');

INSERT INTO schema_migrations (version) VALUES ('20101014154058');

INSERT INTO schema_migrations (version) VALUES ('20101014154329');

INSERT INTO schema_migrations (version) VALUES ('20101014154431');

INSERT INTO schema_migrations (version) VALUES ('20101014182545');

INSERT INTO schema_migrations (version) VALUES ('20101015142219');

INSERT INTO schema_migrations (version) VALUES ('20101020153730');

INSERT INTO schema_migrations (version) VALUES ('20101020154254');

INSERT INTO schema_migrations (version) VALUES ('20101020160734');

INSERT INTO schema_migrations (version) VALUES ('20101026120732');

INSERT INTO schema_migrations (version) VALUES ('20101026132818');

INSERT INTO schema_migrations (version) VALUES ('20101027163423');

INSERT INTO schema_migrations (version) VALUES ('20101029094255');

INSERT INTO schema_migrations (version) VALUES ('20101029094851');

INSERT INTO schema_migrations (version) VALUES ('20101029100120');

INSERT INTO schema_migrations (version) VALUES ('20101101121253');

INSERT INTO schema_migrations (version) VALUES ('20101109094231');

INSERT INTO schema_migrations (version) VALUES ('20110218154148');

INSERT INTO schema_migrations (version) VALUES ('20110223100045');

INSERT INTO schema_migrations (version) VALUES ('20110223104446');

INSERT INTO schema_migrations (version) VALUES ('20110223162819');

INSERT INTO schema_migrations (version) VALUES ('20110503094739');

INSERT INTO schema_migrations (version) VALUES ('20110520085745');

INSERT INTO schema_migrations (version) VALUES ('20110607090547');

INSERT INTO schema_migrations (version) VALUES ('20110607151214');

INSERT INTO schema_migrations (version) VALUES ('20110621154201');

INSERT INTO schema_migrations (version) VALUES ('20110621154323');

INSERT INTO schema_migrations (version) VALUES ('20110708100848');

INSERT INTO schema_migrations (version) VALUES ('20110721160737');

INSERT INTO schema_migrations (version) VALUES ('20110725095224');

INSERT INTO schema_migrations (version) VALUES ('20110725100948');

INSERT INTO schema_migrations (version) VALUES ('20110725114346');

INSERT INTO schema_migrations (version) VALUES ('20110729145916');

INSERT INTO schema_migrations (version) VALUES ('20110803104501');

INSERT INTO schema_migrations (version) VALUES ('20110803130724');

INSERT INTO schema_migrations (version) VALUES ('20110803133253');

INSERT INTO schema_migrations (version) VALUES ('20110804102726');

INSERT INTO schema_migrations (version) VALUES ('20110823101719');

INSERT INTO schema_migrations (version) VALUES ('20110922143443');

INSERT INTO schema_migrations (version) VALUES ('20110923133020');

INSERT INTO schema_migrations (version) VALUES ('20120116135431');

INSERT INTO schema_migrations (version) VALUES ('20120116135432');

INSERT INTO schema_migrations (version) VALUES ('20130730164507');

INSERT INTO schema_migrations (version) VALUES ('20130905092258');

INSERT INTO schema_migrations (version) VALUES ('20130906113219');

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