<%@ page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Task" %>
<%@ page import="model.Campaign" %>
<%
    List<Task> tasks    = (List<Task>)   request.getAttribute("tasks");
    Campaign   campaign = (Campaign)     request.getAttribute("campaign");
    String     ctx      = request.getContextPath();
    if (campaign == null) { response.sendRedirect(ctx + "/campaigns"); return; }

    /* ── Aggregate task metrics ─────────────────────────── */
    int    totalTaskLeads = 0;
    double totalTaskCost  = 0;
    int    pendingCount   = 0, inProgressCount = 0, completedCount = 0;

    if (tasks != null) {
        for (Task t : tasks) {
            totalTaskLeads += t.getLeadsGenerated();
            totalTaskCost  += t.getCost();
            if      ("Pending".equalsIgnoreCase(t.getStatus()))     pendingCount++;
            else if ("In Progress".equalsIgnoreCase(t.getStatus())) inProgressCount++;
            else if ("Completed".equalsIgnoreCase(t.getStatus()))   completedCount++;
        }
    }
    int    taskTotal    = tasks != null ? tasks.size() : 0;
    int    completePct  = taskTotal > 0 ? Math.round(100f * completedCount  / taskTotal) : 0;
    int    inProgPct    = taskTotal > 0 ? Math.round(100f * inProgressCount / taskTotal) : 0;
    int    pendingPct   = taskTotal > 0 ? Math.round(100f * pendingCount    / taskTotal) : 0;

    /* Budget utilisation */
    double budgetUsedPct = campaign.getBudget() > 0
                           ? Math.min(100.0, (totalTaskCost / campaign.getBudget()) * 100.0)
                           : 0.0;
    boolean overBudget = totalTaskCost > campaign.getBudget() && campaign.getBudget() > 0;

    /* Campaign status badge */
    String sc = "badge-planned";
    if      ("Active".equalsIgnoreCase(campaign.getStatus()))    sc = "badge-active";
    else if ("Completed".equalsIgnoreCase(campaign.getStatus())) sc = "badge-completed";

    /* Cost-per-lead for this campaign's tasks */
    double taskCpl = totalTaskLeads > 0 ? totalTaskCost / totalTaskLeads : 0.0;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tasks — <%= campaign.getName() %> — Marketing Campaign Planner</title>
    <meta name="description" content="Task performance overview and management for <%= campaign.getName() %>.">
    <link rel="stylesheet" href="<%= ctx %>/css/style.css">
    <style>
        /* ── Task-page-specific extras ───────────────────────── */

        /* Donut ring chart (pure CSS) */
        .donut-wrap {
            position: relative;
            width: 80px;
            height: 80px;
            flex-shrink: 0;
        }
        .donut-svg { transform: rotate(-90deg); }
        .donut-bg  { fill: none; stroke: var(--border-light); stroke-width: 10; }
        .donut-fill {
            fill: none;
            stroke-width: 10;
            stroke-linecap: round;
            transition: stroke-dasharray 1.4s cubic-bezier(0.22,1,0.36,1);
        }
        .donut-label {
            position: absolute;
            inset: 0;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            line-height: 1.1;
        }
        .donut-pct {
            font-family: 'Outfit', sans-serif;
            font-size: 1.15rem;
            font-weight: 800;
            color: var(--text);
            letter-spacing: -0.03em;
        }
        .donut-sub {
            font-size: 0.55rem;
            color: var(--text-muted);
            font-weight: 600;
            letter-spacing: 0.04em;
            text-transform: uppercase;
        }

        /* Campaign overview banner */
        .campaign-banner {
            border-radius: var(--r);
            padding: 22px 28px;
            margin-bottom: 22px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 20px;
            position: relative;
            overflow: hidden;
            background: linear-gradient(135deg, #1E1B3A 0%, #2D2A5A 50%, #1A1730 100%);
            border: 1px solid rgba(255,255,255,0.07);
            box-shadow: 0 10px 36px rgba(15,13,26,0.30);
        }

        .campaign-banner-grid {
            position: absolute;
            inset: 0;
            background-image:
                linear-gradient(rgba(255,255,255,0.025) 1px, transparent 1px),
                linear-gradient(90deg, rgba(255,255,255,0.025) 1px, transparent 1px);
            background-size: 28px 28px;
            pointer-events: none;
        }

        .campaign-banner::before {
            content: '';
            position: absolute;
            top: -60px; right: -40px;
            width: 240px; height: 240px;
            border-radius: 50%;
            background: radial-gradient(circle, rgba(99,102,241,0.15) 0%, transparent 70%);
            pointer-events: none;
        }

        .cb-left  { position: relative; z-index: 1; }
        .cb-right { position: relative; z-index: 1; display: flex; gap: 28px; flex-wrap: wrap; }

        .cb-eyebrow {
            font-size: 0.64rem;
            font-weight: 700;
            letter-spacing: 0.12em;
            text-transform: uppercase;
            color: rgba(165,180,252,0.70);
            margin-bottom: 8px;
            display: flex;
            align-items: center;
            gap: 7px;
        }

        .cb-eyebrow::before {
            content: '';
            width: 12px; height: 2px;
            background: rgba(165,180,252,0.5);
            border-radius: 2px;
        }

        .cb-name {
            font-family: 'Outfit', 'Inter', sans-serif;
            font-size: 1.55rem;
            font-weight: 800;
            color: #fff;
            letter-spacing: -0.025em;
            line-height: 1.1;
            max-width: 380px;
        }

        .cb-meta {
            font-size: 0.75rem;
            color: rgba(255,255,255,0.45);
            margin-top: 8px;
            display: flex;
            align-items: center;
            gap: 10px;
            flex-wrap: wrap;
        }

        .cb-meta-dot {
            width: 3px; height: 3px;
            background: rgba(255,255,255,0.25);
            border-radius: 50%;
        }

        .cb-stat { text-align: right; }

        .cb-stat-label {
            font-size: 0.65rem;
            letter-spacing: 0.08em;
            text-transform: uppercase;
            color: rgba(255,255,255,0.40);
            margin-bottom: 4px;
        }

        .cb-stat-val {
            font-family: 'Outfit', 'Inter', sans-serif;
            font-size: 1.3rem;
            font-weight: 800;
            color: #fff;
            letter-spacing: -0.02em;
        }

        .cb-divider {
            width: 1px;
            background: rgba(255,255,255,0.10);
            align-self: stretch;
        }

        /* Task stat card layout tweak */
        .task-stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(170px, 1fr));
            gap: 16px;
            margin-bottom: 22px;
        }

        /* Budget bar card */
        .budget-card {
            background: var(--bg-card);
            border-radius: var(--r);
            padding: 20px 22px;
            box-shadow: var(--shadow);
            border: 1px solid var(--border);
            display: flex;
            flex-direction: column;
            gap: 14px;
        }

        .budget-card-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .budget-card-title {
            font-size: 0.80rem;
            font-weight: 700;
            color: var(--text-muted);
            letter-spacing: 0.06em;
            text-transform: uppercase;
        }

        .budget-row {
            display: flex;
            align-items: baseline;
            gap: 6px;
        }

        .budget-used {
            font-family: 'Outfit', sans-serif;
            font-size: 1.6rem;
            font-weight: 800;
            color: var(--text);
            letter-spacing: -0.03em;
        }

        .budget-total {
            font-size: 0.85rem;
            color: var(--text-muted);
            font-weight: 500;
        }

        .budget-bar-wrap {
            background: var(--border-light);
            border-radius: 100px;
            height: 8px;
            overflow: hidden;
        }

        .budget-bar-fill {
            height: 100%;
            border-radius: 100px;
            transition: width 1.4s cubic-bezier(0.22,1,0.36,1);
            background: linear-gradient(90deg, var(--primary), var(--secondary));
        }

        .budget-bar-fill.over { background: linear-gradient(90deg, var(--warning), var(--danger)); }

        .budget-footer {
            display: flex;
            align-items: center;
            justify-content: space-between;
            font-size: 0.72rem;
            color: var(--text-muted);
        }

        /* Completion donut + stats row */
        .completion-card {
            background: var(--bg-card);
            border-radius: var(--r);
            padding: 20px 22px;
            box-shadow: var(--shadow);
            border: 1px solid var(--border);
            display: flex;
            align-items: center;
            gap: 20px;
            flex-wrap: wrap;
        }

        .completion-breakdown {
            flex: 1;
            min-width: 180px;
            display: flex;
            flex-direction: column;
            gap: 9px;
        }

        .breakdown-row {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .breakdown-dot {
            width: 8px; height: 8px;
            border-radius: 50%;
            flex-shrink: 0;
        }

        .breakdown-label {
            font-size: 0.76rem;
            color: var(--text-muted);
            font-weight: 500;
            flex: 1;
        }

        .breakdown-count {
            font-family: 'Outfit', sans-serif;
            font-size: 0.88rem;
            font-weight: 700;
            color: var(--text);
        }

        .breakdown-bar {
            width: 60px;
            height: 4px;
            background: var(--border-light);
            border-radius: 100px;
            overflow: hidden;
            flex-shrink: 0;
        }

        .breakdown-bar-fill {
            height: 100%;
            border-radius: 100px;
            transition: width 1.2s cubic-bezier(0.22,1,0.36,1);
        }

        @media (max-width: 760px) {
            .cb-right { flex-direction: column; gap: 14px; }
            .cb-divider { display: none; }
            .cb-stat { text-align: left; }
        }
    </style>
</head>
<body>

<%@ include file="/WEB-INF/includes/nav.jsp" %>

<div class="main-content">

    <header class="page-header">
        <div class="page-header-left">
            <h1>Task Overview</h1>
            <p><%= campaign.getName() %> &mdash; <span class="type-pill" style="font-size:0.73rem;"><%= campaign.getType() %></span></p>
        </div>
        <div class="page-header-right">
            <a href="<%= ctx %>/campaigns" class="btn btn-outline btn-sm" id="backToCampaignsBtn">← Campaigns</a>
            <a href="<%= ctx %>/addTask?campaignId=<%= campaign.getId() %>"
               class="btn btn-primary" id="addTaskBtn">➕ Add Task</a>
        </div>
    </header>

    <main class="content-area">

        <!-- Breadcrumb -->
        <div class="breadcrumb">
            <a href="<%= ctx %>/dashboard">Dashboard</a>
            <span class="sep">›</span>
            <a href="<%= ctx %>/campaigns">Campaigns</a>
            <span class="sep">›</span>
            <span><%= campaign.getName() %> — Tasks</span>
        </div>

        <!-- ══════════════════════════════════════════════════ -->
        <!--  PERFORMANCE OVERVIEW SECTION                      -->
        <!-- ══════════════════════════════════════════════════ -->

        <div class="section-header">
            <span class="section-title">Performance Overview</span>
            <div class="section-line"></div>
        </div>

        <!-- ── Row 1: Task Stat Cards ─────────────────────── -->
        <div class="task-stats-grid stagger">

            <!-- Total Tasks -->
            <div class="stat-card indigo fade-up" data-icon="📋">
                <div class="stat-top">
                    <div class="stat-icon-pill">📋</div>
                    <span class="stat-trend">All</span>
                </div>
                <div class="stat-body">
                    <div class="stat-value" data-count="<%= taskTotal %>">0</div>
                    <div class="stat-label">Total Tasks</div>
                </div>
                <div class="stat-progress">
                    <div class="stat-progress-bar">
                        <div class="stat-progress-fill" style="width:0%;" data-w="100"></div>
                    </div>
                    <div class="stat-progress-label">100% of total</div>
                </div>
            </div>

            <!-- In Progress -->
            <div class="stat-card amber fade-up" data-icon="🔄">
                <div class="stat-top">
                    <div class="stat-icon-pill">🔄</div>
                    <span class="stat-trend"><%= inProgPct %>%</span>
                </div>
                <div class="stat-body">
                    <div class="stat-value" data-count="<%= inProgressCount %>">0</div>
                    <div class="stat-label">In Progress</div>
                </div>
                <div class="stat-progress">
                    <div class="stat-progress-bar">
                        <div class="stat-progress-fill" style="width:0%;background:linear-gradient(90deg,var(--warning),var(--amber));" data-w="<%= inProgPct %>"></div>
                    </div>
                    <div class="stat-progress-label"><%= inProgPct %>% of total</div>
                </div>
            </div>

            <!-- Completed -->
            <div class="stat-card green fade-up" data-icon="✅">
                <div class="stat-top">
                    <div class="stat-icon-pill">✅</div>
                    <span class="stat-trend"><%= completePct %>%</span>
                </div>
                <div class="stat-body">
                    <div class="stat-value" data-count="<%= completedCount %>">0</div>
                    <div class="stat-label">Completed</div>
                </div>
                <div class="stat-progress">
                    <div class="stat-progress-bar">
                        <div class="stat-progress-fill" style="width:0%;background:linear-gradient(90deg,var(--success),var(--teal));" data-w="<%= completePct %>"></div>
                    </div>
                    <div class="stat-progress-label"><%= completePct %>% done</div>
                </div>
            </div>

            <!-- Pending -->
            <div class="stat-card purple fade-up" data-icon="⏳">
                <div class="stat-top">
                    <div class="stat-icon-pill">⏳</div>
                    <span class="stat-trend"><%= pendingPct %>%</span>
                </div>
                <div class="stat-body">
                    <div class="stat-value" data-count="<%= pendingCount %>">0</div>
                    <div class="stat-label">Pending</div>
                </div>
                <div class="stat-progress">
                    <div class="stat-progress-bar">
                        <div class="stat-progress-fill" style="width:0%;background:linear-gradient(90deg,var(--secondary),var(--rose));" data-w="<%= pendingPct %>"></div>
                    </div>
                    <div class="stat-progress-label"><%= pendingPct %>% of total</div>
                </div>
            </div>

            <!-- Total Leads -->
            <div class="stat-card teal fade-up" data-icon="🎯">
                <div class="stat-top">
                    <div class="stat-icon-pill">🎯</div>
                    <span class="stat-trend">Leads</span>
                </div>
                <div class="stat-body">
                    <div class="stat-value" data-count="<%= totalTaskLeads %>">0</div>
                    <div class="stat-label">Total Leads Generated</div>
                </div>
                <div class="stat-progress">
                    <div class="stat-progress-bar">
                        <div class="stat-progress-fill" style="width:0%;background:linear-gradient(90deg,var(--teal),var(--info));" data-w="<%= totalTaskLeads > 0 ? 75 : 0 %>"></div>
                    </div>
                    <div class="stat-progress-label">
                        CPL: <%= totalTaskLeads > 0 ? "₹" + String.format("%,.2f", taskCpl) : "—" %>
                    </div>
                </div>
            </div>

        </div>

        <!-- ── Row 2: Campaign Banner ──────────────────────── -->
        <div class="campaign-banner fade-up" style="animation-delay:0.28s;">
            <div class="campaign-banner-grid"></div>

            <div class="cb-left">
                <div class="cb-eyebrow">Campaign Overview</div>
                <div class="cb-name"><%= campaign.getName() %></div>
                <div class="cb-meta">
                    <span class="badge <%= sc %>"><%= campaign.getStatus() %></span>
                    <div class="cb-meta-dot"></div>
                    <span><%= campaign.getType() %></span>
                    <div class="cb-meta-dot"></div>
                    <span><%= campaign.getStartDate() %> → <%= campaign.getEndDate() %></span>
                </div>
            </div>

            <div class="cb-right">
                <div class="cb-stat">
                    <div class="cb-stat-label">Budget Allocated</div>
                    <div class="cb-stat-val">₹<%= String.format("%,.0f", campaign.getBudget()) %></div>
                </div>
                <div class="cb-divider"></div>
                <div class="cb-stat">
                    <div class="cb-stat-label">Task Cost Used</div>
                    <div class="cb-stat-val" style="<%= overBudget ? "color:var(--danger);" : "" %>">
                        ₹<%= String.format("%,.0f", totalTaskCost) %>
                    </div>
                </div>
                <div class="cb-divider"></div>
                <div class="cb-stat">
                    <div class="cb-stat-label">Leads Generated</div>
                    <div class="cb-stat-val" style="color:var(--teal-light);"><%= totalTaskLeads %></div>
                </div>
                <div class="cb-divider"></div>
                <div class="cb-stat">
                    <div class="cb-stat-label">Campaign Leads</div>
                    <div class="cb-stat-val" style="color:var(--primary-light);"><%= campaign.getLeads() %></div>
                </div>
            </div>
        </div>

        <!-- ── Row 3: Budget Card + Completion Donut ─────── -->
        <div style="display:grid;grid-template-columns:1fr 1fr;gap:16px;margin-bottom:22px;" class="two-col-metrics fade-up" style="animation-delay:0.34s;">

            <!-- Budget utilisation -->
            <div class="budget-card">
                <div class="budget-card-header">
                    <span class="budget-card-title">💰 Budget Utilisation</span>
                    <span class="stat-trend" style="--sc:var(--<%= overBudget ? "danger" : "primary" %>);--sc-light:var(--<%= overBudget ? "danger-xlight" : "primary-xlight" %>);">
                        <%= String.format("%.1f", budgetUsedPct) %>%
                    </span>
                </div>
                <div>
                    <div class="budget-row">
                        <span class="budget-used">₹<%= String.format("%,.2f", totalTaskCost) %></span>
                        <span class="budget-total">of ₹<%= String.format("%,.2f", campaign.getBudget()) %></span>
                    </div>
                    <% if (overBudget) { %>
                    <div style="font-size:0.73rem;color:var(--danger);font-weight:600;margin-top:4px;">
                        ⚠ Over budget by ₹<%= String.format("%,.2f", totalTaskCost - campaign.getBudget()) %>
                    </div>
                    <% } %>
                </div>
                <div>
                    <div class="budget-bar-wrap">
                        <div class="budget-bar-fill <%= overBudget ? "over" : "" %>"
                             style="width:0%;" data-bw="<%= String.format("%.1f", budgetUsedPct) %>">
                        </div>
                    </div>
                    <div class="budget-footer" style="margin-top:7px;">
                        <span>₹<%= String.format("%,.2f", Math.max(0, campaign.getBudget() - totalTaskCost)) %> remaining</span>
                        <span><%= taskTotal %> task<%= taskTotal != 1 ? "s" : "" %></span>
                    </div>
                </div>
            </div>

            <!-- Task completion donut + breakdown -->
            <div class="completion-card">
                <!-- Donut -->
                <div class="donut-wrap">
                    <svg class="donut-svg" width="80" height="80" viewBox="0 0 80 80">
                        <circle class="donut-bg" cx="40" cy="40" r="30"/>
                        <circle class="donut-fill" cx="40" cy="40" r="30"
                                stroke="<%= completePct >= 80 ? "#10B981" : (completePct >= 40 ? "#6366F1" : "#F59E0B") %>"
                                stroke-dasharray="0 188.5"
                                data-pct="<%= completePct %>"
                                style="stroke-dasharray:0 188.5;"/>
                    </svg>
                    <div class="donut-label">
                        <div class="donut-pct"><%= completePct %>%</div>
                        <div class="donut-sub">Done</div>
                    </div>
                </div>

                <!-- Breakdown -->
                <div class="completion-breakdown">
                    <div style="font-size:0.78rem;font-weight:700;color:var(--text);margin-bottom:2px;">Task Completion</div>

                    <div class="breakdown-row">
                        <div class="breakdown-dot" style="background:var(--success);"></div>
                        <span class="breakdown-label">Completed</span>
                        <div class="breakdown-bar">
                            <div class="breakdown-bar-fill" style="width:0%;background:var(--success);" data-bw="<%= completePct %>"></div>
                        </div>
                        <span class="breakdown-count"><%= completedCount %></span>
                    </div>

                    <div class="breakdown-row">
                        <div class="breakdown-dot" style="background:var(--warning);"></div>
                        <span class="breakdown-label">In Progress</span>
                        <div class="breakdown-bar">
                            <div class="breakdown-bar-fill" style="width:0%;background:var(--warning);" data-bw="<%= inProgPct %>"></div>
                        </div>
                        <span class="breakdown-count"><%= inProgressCount %></span>
                    </div>

                    <div class="breakdown-row">
                        <div class="breakdown-dot" style="background:var(--secondary);"></div>
                        <span class="breakdown-label">Pending</span>
                        <div class="breakdown-bar">
                            <div class="breakdown-bar-fill" style="width:0%;background:var(--secondary);" data-bw="<%= pendingPct %>"></div>
                        </div>
                        <span class="breakdown-count"><%= pendingCount %></span>
                    </div>

                    <div style="margin-top:4px;font-size:0.70rem;color:var(--text-muted);">
                        <%= taskTotal %> task<%= taskTotal!=1?"s":"" %> total
                        <% if (taskTotal > 0) { %> &bull; <%= taskTotal - completedCount %> remaining<% } %>
                    </div>
                </div>
            </div>

        </div>

        <!-- ══════════════════════════════════════════════════ -->
        <!--  TASK TABLE SECTION                                -->
        <!-- ══════════════════════════════════════════════════ -->

        <div class="section-header">
            <span class="section-title">Task Management</span>
            <div class="section-line"></div>
        </div>

        <!-- Toolbar -->
        <div class="toolbar" id="taskToolbar">
            <div class="search-wrap">
                <svg class="search-icon-svg" viewBox="0 0 20 20" fill="none" stroke="currentColor" stroke-width="1.8">
                    <circle cx="9" cy="9" r="6"/><path d="M15 15l-3.5-3.5"/>
                </svg>
                <input type="text" class="search-input" id="taskSearch"
                       placeholder="Search tasks…" aria-label="Search tasks">
            </div>
            <div class="filter-group">
                <span class="filter-label-icon">🎯</span>
                <select class="filter-select" id="taskStatusFilter" aria-label="Filter by status">
                    <option value="">All Statuses</option>
                    <option value="Pending">Pending</option>
                    <option value="In Progress">In Progress</option>
                    <option value="Completed">Completed</option>
                </select>
                <span class="filter-arrow">▾</span>
            </div>
            <div class="filter-group">
                <span class="filter-label-icon">📌</span>
                <select class="filter-select" id="taskTypeFilter" aria-label="Filter by type">
                    <option value="">All Types</option>
                    <option value="Design">Design</option>
                    <option value="Content">Content</option>
                    <option value="Launch">Launch</option>
                    <option value="Research">Research</option>
                    <option value="Analysis">Analysis</option>
                    <option value="Outreach">Outreach</option>
                    <option value="Other">Other</option>
                </select>
                <span class="filter-arrow">▾</span>
            </div>
            <div class="toolbar-count" id="taskCount">
                <span id="visibleTaskCount"><%= taskTotal %></span> / <%= taskTotal %> task<%= taskTotal!=1?"s":"" %>
            </div>
            <div style="margin-left:auto;">
                <a href="<%= ctx %>/addTask?campaignId=<%= campaign.getId() %>"
                   class="btn btn-primary btn-sm" id="addTaskToolbarBtn">➕ Add Task</a>
            </div>
        </div>

        <!-- Task table card -->
        <div class="card fade-up" style="animation-delay:0.18s;">
            <div class="card-header">
                <h3>🗂 Tasks
                    <span style="font-size:0.73rem;font-weight:500;color:var(--text-muted);margin-left:4px;">
                        (<span id="cardTaskCount"><%= taskTotal %></span> total)
                    </span>
                </h3>
                <div style="display:flex;gap:8px;align-items:center;flex-wrap:wrap;">
                    <% if (pendingCount > 0) { %>
                    <span class="badge badge-pending"><%= pendingCount %> pending</span>
                    <% } %>
                    <% if (inProgressCount > 0) { %>
                    <span class="badge badge-in-progress"><%= inProgressCount %> in progress</span>
                    <% } %>
                    <% if (completedCount > 0) { %>
                    <span class="badge badge-completed"><%= completedCount %> done</span>
                    <% } %>
                </div>
            </div>

            <% if (tasks == null || tasks.isEmpty()) { %>
            <div class="empty-state">
                <div class="empty-icon">📝</div>
                <h3>No tasks yet</h3>
                <p>Add tasks to break this campaign into clear, actionable steps and start tracking progress.</p>
                <a href="<%= ctx %>/addTask?campaignId=<%= campaign.getId() %>"
                   class="btn btn-primary" id="emptyAddTaskBtn">➕ Add First Task</a>
            </div>
            <% } else { %>
            <div class="table-wrapper">
                <table id="taskTable">
                    <thead>
                        <tr>
                            <th style="width:40px;">#</th>
                            <th>Title</th>
                            <th>Type</th>
                            <th>Deadline</th>
                            <th style="text-align:right;">Cost (₹)</th>
                            <th>Status</th>
                            <th style="text-align:center;">🎯 Leads</th>
                            <th>Quick Update</th>
                            <th style="width:130px;">Actions</th>
                        </tr>
                    </thead>
                    <tbody id="taskTbody">
                    <% int rn = 1; for (Task t : tasks) {
                           String ts = "badge-pending";
                           if      ("In Progress".equalsIgnoreCase(t.getStatus())) ts = "badge-in-progress";
                           else if ("Completed".equalsIgnoreCase(t.getStatus()))   ts = "badge-completed";
                    %>
                        <tr class="task-row"
                            data-title="<%= t.getTitle().toLowerCase() %>"
                            data-status="<%= t.getStatus() %>"
                            data-type="<%= t.getType() %>">
                            <td class="text-muted text-xs num" style="text-align:center;"><%= rn++ %></td>
                            <td class="col-name"><%= t.getTitle() %></td>
                            <td><span class="type-pill"><%= t.getType() %></span></td>
                            <td class="text-sm"><%= t.getDeadline() %></td>
                            <td style="text-align:right;font-variant-numeric:tabular-nums;">₹<%= String.format("%,.2f", t.getCost()) %></td>
                            <td><span class="badge <%= ts %>"><%= t.getStatus() %></span></td>
                            <td style="text-align:center;font-weight:800;font-family:'Outfit',sans-serif;color:var(--teal-dark);font-variant-numeric:tabular-nums;">
                                <%= t.getLeadsGenerated() %>
                            </td>

                            <!-- Quick inline update -->
                            <td>
                                <form action="<%= ctx %>/quickUpdateTask" method="post"
                                      class="quick-form" id="qf_<%= t.getId() %>">
                                    <input type="hidden" name="id"         value="<%= t.getId() %>">
                                    <input type="hidden" name="campaignId" value="<%= campaign.getId() %>">
                                    <select name="status" title="Status" aria-label="Task status">
                                        <option value="Pending"     <%= "Pending".equalsIgnoreCase(t.getStatus())     ? "selected":"" %>>Pending</option>
                                        <option value="In Progress" <%= "In Progress".equalsIgnoreCase(t.getStatus()) ? "selected":"" %>>In Progress</option>
                                        <option value="Completed"   <%= "Completed".equalsIgnoreCase(t.getStatus())   ? "selected":"" %>>Done</option>
                                    </select>
                                    <input type="number" name="leadsGenerated"
                                           value="<%= t.getLeadsGenerated() %>"
                                           min="0" title="Leads" placeholder="Leads"
                                           aria-label="Leads generated">
                                    <button type="submit" class="btn btn-teal btn-xs"
                                            id="qfSave_<%= t.getId() %>" title="Save">✓</button>
                                </form>
                            </td>

                            <td>
                                <div class="actions-cell">
                                    <a href="<%= ctx %>/editTask?id=<%= t.getId() %>"
                                       class="btn btn-warning btn-sm" title="Edit task"
                                       id="editTaskBtn_<%= t.getId() %>">✏️ Edit</a>
                                    <a href="<%= ctx %>/deleteTask?id=<%= t.getId() %>&campaignId=<%= campaign.getId() %>"
                                       class="btn btn-danger btn-sm" title="Delete task"
                                       id="deleteTaskBtn_<%= t.getId() %>"
                                       onclick="return confirm('Delete this task? This cannot be undone.')">🗑</a>
                                </div>
                            </td>
                        </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>

            <!-- No results after filter -->
            <div id="noResults" class="empty-state" style="display:none;padding:36px 20px;">
                <div class="empty-icon" style="font-size:2.5rem;">🔍</div>
                <h3 style="font-size:1rem;">No matching tasks</h3>
                <p>Try adjusting your search or filter.</p>
            </div>

            <% } %>
        </div>

        <!-- Back link -->
        <div style="margin-top:22px;">
            <a href="<%= ctx %>/campaigns" class="btn btn-outline" id="backToCampaignsFooterBtn">← Back to Campaigns</a>
        </div>

    </main>
</div>

<div class="toast-container" id="toastContainer"></div>

<script>
window.addEventListener('DOMContentLoaded', function() {

    /* ── Animate stat counters ── */
    function countUp(el, target, ms) {
        if (target === 0) return;
        var step = 16, inc = target / (ms / step), cur = 0;
        var timer = setInterval(function() {
            cur += inc;
            if (cur >= target) { cur = target; clearInterval(timer); }
            el.textContent = Math.round(cur);
        }, step);
    }

    document.querySelectorAll('.stat-value[data-count]').forEach(function(el) {
        countUp(el, parseInt(el.getAttribute('data-count'), 10) || 0, 900);
    });

    /* ── Reveal progress bars ── */
    setTimeout(function() {
        document.querySelectorAll('.stat-progress-fill[data-w]').forEach(function(el) {
            el.style.width = el.getAttribute('data-w') + '%';
        });
        document.querySelectorAll('.breakdown-bar-fill[data-bw]').forEach(function(el) {
            el.style.width = el.getAttribute('data-bw') + '%';
        });
        document.querySelectorAll('.budget-bar-fill[data-bw]').forEach(function(el) {
            el.style.width = el.getAttribute('data-bw') + '%';
        });
    }, 350);

    /* ── Animate donut ring ── */
    setTimeout(function() {
        var circle = document.querySelector('.donut-fill[data-pct]');
        if (!circle) return;
        var pct = parseInt(circle.getAttribute('data-pct'), 10) || 0;
        var circumference = 2 * Math.PI * 30; /* r=30 */
        var filled = (pct / 100) * circumference;
        circle.style.strokeDasharray = filled + ' ' + (circumference - filled);
    }, 400);

    /* ── Live search & filter ── */
    var search  = document.getElementById('taskSearch');
    var byStat  = document.getElementById('taskStatusFilter');
    var byType  = document.getElementById('taskTypeFilter');
    var tbody   = document.getElementById('taskTbody');
    var noRes   = document.getElementById('noResults');
    var countEl = document.getElementById('visibleTaskCount');
    var cardCnt = document.getElementById('cardTaskCount');

    function filterTasks() {
        if (!tbody) return;
        var q  = search  ? search.value.toLowerCase() : '';
        var st = byStat  ? byStat.value  : '';
        var ty = byType  ? byType.value  : '';
        var n  = 0;
        tbody.querySelectorAll('.task-row').forEach(function(row) {
            var ok = row.getAttribute('data-title').includes(q)
                  && (!st || row.getAttribute('data-status') === st)
                  && (!ty || row.getAttribute('data-type')   === ty);
            row.style.display = ok ? '' : 'none';
            if (ok) n++;
        });
        if (countEl) countEl.textContent = n;
        if (cardCnt) cardCnt.textContent = n;
        if (noRes)   noRes.style.display = n === 0 ? 'block' : 'none';
    }

    if (search) search.addEventListener('input', filterTasks);
    if (byStat) byStat.addEventListener('change', filterTasks);
    if (byType) byType.addEventListener('change', filterTasks);

    /* ── Quick form spinner ── */
    document.querySelectorAll('.quick-form').forEach(function(form) {
        form.addEventListener('submit', function() {
            var btn = form.querySelector('button[type="submit"]');
            if (btn) { btn.textContent = '…'; btn.disabled = true; }
        });
    });

    /* ── Responsive two-col layout ── */
    function checkGrid() {
        var el = document.querySelector('.two-col-metrics');
        if (!el) return;
        if (window.innerWidth < 700) {
            el.style.gridTemplateColumns = '1fr';
        } else {
            el.style.gridTemplateColumns = '1fr 1fr';
        }
    }
    checkGrid();
    window.addEventListener('resize', checkGrid);
});
</script>

</body>
</html>
