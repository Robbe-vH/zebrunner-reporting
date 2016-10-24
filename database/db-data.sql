INSERT INTO zafira.SETTINGS (NAME, VALUE) VALUES ('STF_NOTIFICATION_RECIPIENTS', '');

DO $$
DECLARE dashboard_id zafira.DASHBOARDS.id%TYPE;
DECLARE widget_id zafira.WIDGETS.id%TYPE;

DECLARE general_dashboard_id zafira.DASHBOARDS.id%TYPE;
DECLARE result_widget_id zafira.WIDGETS.id%TYPE;
DECLARE top_widget_id zafira.WIDGETS.id%TYPE;
DECLARE progress_widget_id zafira.WIDGETS.id%TYPE;

BEGIN
  INSERT INTO zafira.DASHBOARDS (TITLE, TYPE) VALUES ('Performance dashboard', 'PERFORMANCE') RETURNING id INTO dashboard_id;

  INSERT INTO zafira.WIDGETS (TITLE, TYPE, SQL, MODEL) VALUES ('Performance widget', 'linechart',
	'set schema zafira;
SELECT TEST_CONFIGS.ENV || "-" || TEST_CONFIGS.DEVICE AS env, 
	TEST_METRICS.OPERATION, 
	TEST_METRICS.ELAPSED AS "ELAPSED",
	TEST_METRICS.CREATED_AT AS "CREATED_AT"
FROM TEST_METRICS INNER JOIN 
	TESTS ON TEST_METRICS.TEST_ID = TESTS.ID INNER JOIN
	TEST_CONFIGS ON TEST_CONFIGS.ID = TESTS.TEST_CONFIG_ID
WHERE TESTS.TEST_CASE_ID = #{test_case_id} #{time_step}
ORDER BY env, "CREATED_AT"',
    '{"series":[{"axis":"y","dataset":"dataset","key":"ELAPSED","label":"ELAPSED","color":"#5cb85c","thickness":"10px",
    	"type":["line","dot"],"id":"ELAPSED"}],"axes":{"x":{"key":"CREATED_AT","type":"int","ticks": "functions(value) {return ''wow!''}"}}}')
    RETURNING id INTO widget_id;

	INSERT INTO zafira.DASHBOARDS_WIDGETS (DASHBOARD_ID, WIDGET_ID, POSITION, SIZE) VALUES (dashboard_id, widget_id, 1, 12);
	
	
	
	
	INSERT INTO zafira.DASHBOARDS (TITLE, TYPE) VALUES ('General', 'GENERAL') RETURNING id INTO general_dashboard_id;
	
	INSERT INTO zafira.WIDGETS (TITLE, TYPE, SQL, MODEL) VALUES ('Test results (last 30 days)', 'linechart',
		'set schema ''zafira'';
SELECT 
	sum( case when TESTS.STATUS = ''PASSED'' then 1 else 0 end ) AS "PASSED",  
	sum( case when TESTS.STATUS = ''FAILED'' then 1 else 0 end ) AS "FAILED", 
	sum( case when TESTS.STATUS = ''SKIPPED'' then 1 else 0 end ) AS "SKIPPED", 
	sum( case when TESTS.STATUS = ''IN_PROGRESS'' then 1 else 0 end ) AS "INCOMPLETE",
	TESTS.CREATED_AT::date AS "CREATED_AT"  
FROM 
	TESTS INNER JOIN 
TEST_RUNS ON TESTS.TEST_RUN_ID = TEST_RUNS.ID INNER JOIN
PROJECTS ON TEST_RUNS.PROJECT_ID = PROJECTS.ID
WHERE 
	TESTS.CREATED_AT::date >= (current_date - 30) AND PROJECTS.NAME LIKE ''#{project}%''
GROUP BY TESTS.CREATED_AT::date 
ORDER BY TESTS.CREATED_AT::date;',
'{
  "series": [
    {
      "axis": "y",
      "dataset": "dataset",
      "key": "PASSED",
      "label": "PASSED",
      "color": "#5cb85c",
      "thickness": "10px",
      "type": [
        "line",
        "dot",
        "area"
      ],
      "id": "PASSED"
    },
    {
      "axis": "y",
      "dataset": "dataset",
      "key": "FAILED",
      "label": "FAILED",
      "color": "#d9534f",
	  "thickness": "10px",
      "type": [
        "line",
        "dot",
        "area"
      ],
      "id": "FAILED"
    },
    {
      "axis": "y",
      "dataset": "dataset",
      "key": "SKIPPED",
      "label": "SKIPPED",
      "color": "#f0ad4e",
	  "thickness": "10px",
      "type": [
        "line",
        "dot",
        "area"
      ],
      "id": "SKIPPED"
    },
    {
      "axis": "y",
      "dataset": "dataset",
      "key": "INCOMPLETE",
      "label": "INCOMPLETE",
      "color": "#3a87ad",
      "type": [
        "line",
        "dot",
        "area"
      ],
      "id": "INCOMPLETE"
    }
  ],
  "axes": {
    "x": {
      "key": "CREATED_AT",
      "type": "date"
    }
  }
}')
		RETURNING id INTO result_widget_id;
		
		INSERT INTO zafira.WIDGETS (TITLE, TYPE, SQL, MODEL) VALUES ('Top 8 test automation developers', 'piechart',
		'set schema ''zafira'';
SELECT 
	USERS.USERNAME AS "label",
	COUNT(*) AS "value",
	CONCAT(''#'', floor(random()*(999-100+1))+100) AS "color"
FROM 
	TEST_CASES INNER JOIN 
USERS ON USERS.ID = TEST_CASES.USER_ID INNER JOIN 
PROJECTS ON TEST_CASES.PROJECT_ID = PROJECTS.ID
WHERE 
	PROJECTS.NAME LIKE ''#{project}%''
GROUP BY USERS.USERNAME
ORDER BY "value" DESC
LIMIT 8;',
'{}')
		RETURNING id INTO top_widget_id;
		
		INSERT INTO zafira.WIDGETS (TITLE, TYPE, SQL, MODEL) VALUES ('Test implementation progress (last 30 days)', 'linechart',
		'set schema ''zafira'';
SELECT 
	TEST_CASES.CREATED_AT::date AS "CREATED_AT", 
	COUNT(*) AS "AMOUNT"
FROM 
	TEST_CASES INNER JOIN 
PROJECTS ON TEST_CASES.PROJECT_ID = PROJECTS.ID
WHERE 
	TEST_CASES.CREATED_AT::date >= (current_date - 30) AND PROJECTS.NAME LIKE ''#{project}%''
GROUP BY TEST_CASES.CREATED_AT::date
ORDER BY TEST_CASES.CREATED_AT::date ASC;',
'{
  "series": [
    {
      "axis": "y",
      "dataset": "dataset",
      "key": "AMOUNT",
      "label": "AMOUNT",
      "color": "#3a87ad",
      "type": [
        "column"
      ],
      "id": "AMOUNT"
    }
  ],
  "axes": {
    "x": {
      "key": "CREATED_AT",
      "type": "date"
    }
  }
}')
		RETURNING id INTO progress_widget_id;
		
		INSERT INTO zafira.DASHBOARDS_WIDGETS (DASHBOARD_ID, WIDGET_ID, POSITION, SIZE) VALUES (general_dashboard_id, result_widget_id, 0, 12);
		INSERT INTO zafira.DASHBOARDS_WIDGETS (DASHBOARD_ID, WIDGET_ID, POSITION, SIZE) VALUES (general_dashboard_id, top_widget_id, 1, 4);
		INSERT INTO zafira.DASHBOARDS_WIDGETS (DASHBOARD_ID, WIDGET_ID, POSITION, SIZE) VALUES (general_dashboard_id, progress_widget_id, 3, 8);
END$$;