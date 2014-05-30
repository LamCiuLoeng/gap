-- Table: gap_uploadsi_header

-- DROP TABLE gap_uploadsi_header;

CREATE TABLE gap_uploadsi_header
(
  id serial NOT NULL,
  create_time timestamp without time zone,
  last_modify_time timestamp without time zone,
  issued_by_id integer,
  last_modify_by_id integer,
  active integer,
  filename character varying(200),
  filepath character varying(200),
  CONSTRAINT gap_uploadsi_header_pkey PRIMARY KEY (id ),
  CONSTRAINT gap_uploadsi_header_issued_by_id_fkey FOREIGN KEY (issued_by_id)
      REFERENCES tg_user (user_id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT gap_uploadsi_header_last_modify_by_id_fkey FOREIGN KEY (last_modify_by_id)
      REFERENCES tg_user (user_id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE gap_uploadsi_header
  OWNER TO postgres;


-- Table: gap_uploadsi_detail

-- DROP TABLE gap_uploadsi_detail;

CREATE TABLE gap_uploadsi_detail
(
  id serial NOT NULL,
  order_no character varying(200),
  item_number character varying(255),
  invoice_number character varying(200),
  internal_po character varying(200),
  ship_qty integer,
  type integer,
  header_id integer,
  create_time timestamp without time zone,
  last_modify_time timestamp without time zone,
  issued_by_id integer,
  last_modify_by_id integer,
  active integer,
  delivery_date character varying(200),
  CONSTRAINT gap_uploadsi_detail_pkey PRIMARY KEY (id ),
  CONSTRAINT gap_uploadsi_detail_header_id_fkey FOREIGN KEY (header_id)
      REFERENCES gap_uploadsi_header (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT gap_uploadsi_detail_issued_by_id_fkey FOREIGN KEY (issued_by_id)
      REFERENCES tg_user (user_id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT gap_uploadsi_detail_last_modify_by_id_fkey FOREIGN KEY (last_modify_by_id)
      REFERENCES tg_user (user_id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);
ALTER TABLE gap_uploadsi_detail
  OWNER TO postgres;


-- Column: filename

-- ALTER TABLE gap_ship_item_header DROP COLUMN filename;

ALTER TABLE gap_ship_item_header ADD COLUMN filename character varying(200);


-- Column: filepath

-- ALTER TABLE gap_ship_item_header DROP COLUMN filepath;

ALTER TABLE gap_ship_item_header ADD COLUMN filepath character varying(200);
