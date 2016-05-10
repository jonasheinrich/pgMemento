/*
Shows the last revisions/changes for an audited record
*/
CREATE OR REPLACE FUNCTION pgmemento.get_last_revisions(
  table_name TEXT,
  id BIGINT,
  quantity BIGINT
) RETURNS SETOF JSONB AS
$$
DECLARE
  aid BIGINT;
BEGIN
  EXECUTE format(
    'SELECT audit_id FROM %I'
       ' WHERE id=$1', table_name) INTO aid USING id;
  RETURN QUERY
  EXECUTE format(
    'SELECT r.changes FROM pgmemento.row_log r
       JOIN pgmemento.table_event_log e ON r.event_id = e.id
       JOIN pgmemento.transaction_log t ON t.txid = e.transaction_id
       WHERE r.audit_id = $1
       ORDER BY t.stmt_date DESC
       LIMIT $2') USING aid, quantity;
END;
$$
LANGUAGE plpgsql;
