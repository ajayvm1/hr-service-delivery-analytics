CREATE DATABASE meridian_hr;
USE meridian_hr;

SELECT * FROM employees LIMIT 10;
SELECT * FROM hr_tickets LIMIT 10;

-- understanding the date range we are dealing with

SELECT 
    MIN(created_on) AS first_ticket_created,
    MAX(created_on) AS last_ticket_created,
    MIN(sla_deadline) AS first_sla_deadline,
    MAX(sla_deadline) AS last_sla_deadline,
    MIN(resolved_at) AS first_ticket_resolved,
    MAX(resolved_at) AS last_ticket_resolved
FROM hr_tickets;

-- summary of overall ticket volume and SLA performance baseline


SELECT 
    COUNT(*) AS total_tickets,
    SUM(CASE WHEN ticket_status = 'Closed' THEN 1 ELSE 0 END) AS closed_tickets,
    ROUND(AVG(CASE WHEN ticket_status = 'Closed' THEN TIMESTAMPDIFF(HOUR, created_on, resolved_at) END), 2) AS avg_resolution_hours,
    SUM(CASE WHEN ticket_status = 'Closed' AND resolved_at > sla_deadline THEN 1 ELSE 0 END) AS total_breaches,
    ROUND(
        SUM(CASE WHEN ticket_status = 'Closed' AND resolved_at > sla_deadline THEN 1 ELSE 0 END) * 100.0 / 
        NULLIF(SUM(CASE WHEN ticket_status = 'Closed' THEN 1 ELSE 0 END), 0), 2
    ) AS overall_breach_rate_pct
FROM hr_tickets;

-- Checking if priority levels have different SLA time allowances
SELECT 
    priority_level,
    COUNT(ticket_id) AS ticket_count,
    ROUND(AVG(TIMESTAMPDIFF(HOUR, created_on, sla_deadline)), 2) AS avg_hours_allowed,
    MIN(TIMESTAMPDIFF(HOUR, created_on, sla_deadline)) AS min_hours_allowed,
    MAX(TIMESTAMPDIFF(HOUR, created_on, sla_deadline)) AS max_hours_allowed
FROM hr_tickets
GROUP BY priority_level
ORDER BY avg_hours_allowed DESC;

-- Checking if priority levels are randomly distributed across request topics
SELECT 
    request_topic,
    COUNT(ticket_id) AS total_tickets,
    SUM(CASE WHEN priority_level = 'Low' THEN 1 ELSE 0 END) AS low_count,
    SUM(CASE WHEN priority_level = 'Medium' THEN 1 ELSE 0 END) AS medium_count,
    SUM(CASE WHEN priority_level = 'High' THEN 1 ELSE 0 END) AS high_count,
    SUM(CASE WHEN priority_level = 'Critical' THEN 1 ELSE 0 END) AS critical_count
FROM hr_tickets
GROUP BY request_topic;


-- breaking down volume, status, and SLA performance by request topic
SELECT 
    request_topic,
    COUNT(ticket_id) AS total_tickets,
    SUM(CASE WHEN ticket_status = 'Closed' THEN 1 ELSE 0 END) AS closed_tickets,
    SUM(CASE WHEN ticket_status = 'In Progress' THEN 1 ELSE 0 END) AS in_progress_tickets,
    ROUND(AVG(CASE WHEN ticket_status = 'Closed' THEN TIMESTAMPDIFF(HOUR, created_on, resolved_at) END), 2) AS avg_resolution_hours,
    SUM(CASE WHEN ticket_status = 'Closed' AND resolved_at > sla_deadline THEN 1 ELSE 0 END) AS total_breaches,
    ROUND(
        SUM(CASE WHEN ticket_status = 'Closed' AND resolved_at > sla_deadline THEN 1 ELSE 0 END) * 100.0 / 
        NULLIF(SUM(CASE WHEN ticket_status = 'Closed' THEN 1 ELSE 0 END), 0), 2
    ) AS breach_rate_pct
FROM hr_tickets
GROUP BY request_topic
ORDER BY breach_rate_pct DESC;



-- analyzing downstream impact by employee department
SELECT 
    e.dept AS employee_department,
    COUNT(t.ticket_id) AS total_tickets,
    SUM(CASE WHEN t.ticket_status = 'Closed' THEN 1 ELSE 0 END) AS closed_tickets,
    ROUND(AVG(CASE WHEN t.ticket_status = 'Closed' THEN TIMESTAMPDIFF(HOUR, t.created_on, t.resolved_at) END), 2) AS avg_resolution_hours,
    SUM(CASE WHEN t.ticket_status = 'Closed' AND t.resolved_at > t.sla_deadline THEN 1 ELSE 0 END) AS breached_tickets,
    ROUND(
        SUM(CASE WHEN t.ticket_status = 'Closed' AND t.resolved_at > t.sla_deadline THEN 1 ELSE 0 END) * 100.0 / 
        NULLIF(SUM(CASE WHEN t.ticket_status = 'Closed' THEN 1 ELSE 0 END), 0), 2
    ) AS breach_rate_pct
FROM hr_tickets t
LEFT JOIN employees e 
    ON t.emp_id = e.emp_id
GROUP BY e.dept
ORDER BY breach_rate_pct DESC;


-- analyzing SLA performance by office location
SELECT 
    e.office_location,
    COUNT(t.ticket_id) AS total_tickets,
    SUM(CASE WHEN t.ticket_status = 'Closed' THEN 1 ELSE 0 END) AS closed_tickets,
    ROUND(AVG(CASE WHEN t.ticket_status = 'Closed' THEN TIMESTAMPDIFF(HOUR, t.created_on, t.resolved_at) END), 2) AS avg_resolution_hours,
    SUM(CASE WHEN t.ticket_status = 'Closed' AND t.resolved_at > t.sla_deadline THEN 1 ELSE 0 END) AS breached_tickets,
    ROUND(
        SUM(CASE WHEN t.ticket_status = 'Closed' AND t.resolved_at > t.sla_deadline THEN 1 ELSE 0 END) * 100.0 / 
        NULLIF(SUM(CASE WHEN t.ticket_status = 'Closed' THEN 1 ELSE 0 END), 0), 2
    ) AS breach_rate_pct
FROM hr_tickets t
LEFT JOIN employees e 
    ON t.emp_id = e.emp_id
GROUP BY e.office_location
ORDER BY breach_rate_pct DESC;



-- identifying the operational bottleneck by analyzing agent group and priority
SELECT 
    agent_group,
    priority_level,
    COUNT(ticket_id) AS total_tickets,
    SUM(CASE WHEN ticket_status = 'Closed' THEN 1 ELSE 0 END) AS closed_tickets,
    ROUND(AVG(CASE WHEN ticket_status = 'Closed' THEN TIMESTAMPDIFF(HOUR, created_on, resolved_at) END), 2) AS avg_resolution_hours,
    SUM(CASE WHEN ticket_status = 'Closed' AND resolved_at > sla_deadline THEN 1 ELSE 0 END) AS breached_tickets,
    ROUND(
        SUM(CASE WHEN ticket_status = 'Closed' AND resolved_at > sla_deadline THEN 1 ELSE 0 END) * 100.0 / 
        NULLIF(SUM(CASE WHEN ticket_status = 'Closed' THEN 1 ELSE 0 END), 0), 2
    ) AS breach_rate_pct
FROM hr_tickets
GROUP BY agent_group, priority_level
ORDER BY breach_rate_pct DESC;


-- evaluating individual agent workload and performance across all priority tiers
SELECT 
    assigned_agent,
    COUNT(ticket_id) AS total_assigned,
    SUM(CASE WHEN priority_level = 'High' THEN 1 ELSE 0 END) AS high_priority_assigned,
    SUM(CASE WHEN priority_level = 'Medium' THEN 1 ELSE 0 END) AS medium_priority_assigned,
    SUM(CASE WHEN priority_level = 'Low' THEN 1 ELSE 0 END) AS low_priority_assigned,
    SUM(CASE WHEN ticket_status = 'Closed' THEN 1 ELSE 0 END) AS total_closed,
    ROUND(AVG(CASE WHEN ticket_status = 'Closed' THEN TIMESTAMPDIFF(HOUR, created_on, resolved_at) END), 2) AS overall_avg_resolution_hours
FROM hr_tickets
WHERE agent_group = 'HR Case Managers'
GROUP BY assigned_agent
ORDER BY total_assigned DESC;


-- Generating the extract for Tableau 
SELECT 
    t.ticket_id,
    t.emp_id,
    e.first_name,
    e.last_name,
    e.dept AS employee_department,
    e.office_location,
    e.emp_status,
    t.request_topic,
    t.priority_level,
    t.agent_group,
    t.assigned_agent,
    t.created_on,
    t.sla_deadline,
    t.resolved_at,
    t.ticket_status,
    
    -- Pre-calculated metric: Flags the ticket as breached (1) or not breached (0)
    CASE 
        WHEN t.ticket_status = 'Closed' AND t.resolved_at > t.sla_deadline THEN 1 
        ELSE 0 
    END AS is_breached,
    
    -- Pre-calculated metric: Total hours taken to resolve closed tickets
    CASE 
        WHEN t.ticket_status = 'Closed' THEN TIMESTAMPDIFF(HOUR, t.created_on, t.resolved_at) 
    END AS resolution_hours

FROM hr_tickets t
LEFT JOIN employees e 
    ON t.emp_id = e.emp_id;
