<%@ page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Campaign" %>
<%
    List<Campaign> campaigns = (List<Campaign>) request.getAttribute("campaigns");
    String ctx = request.getContextPath();
    int totalCampaigns = campaigns != null ? campaigns.size() : 0;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Campaigns — Marketing Campaign Planner</title>
    <meta name="description" content="List of all marketing campaigns with status, budget, and lead tracking.">
    <link rel="stylesheet" href="<%= ctx %>/css/style.css">
</head>
<body>

<%@ include file="/WEB-INF/includes/nav.jsp" %>

<div class="main-content">

    <header class="page-header">
        <div class="page-header-left">
            <h1>Campaigns</h1>
            <p>Manage and track all your marketing campaigns</p>
        </div>
        <div class="page-header-right">
            <a href="<%= ctx %>/addCampaign" class="btn btn-primary" id="newCampaignBtn">➕ New Campaign</a>
        </div>
    </header>

    <main class="content-area">

        <!-- Toolbar -->
        <div class="toolbar" id="campaignToolbar">

            <!-- Search -->
            <div class="search-wrap">
                <svg class="search-icon-svg" viewBox="0 0 20 20" fill="none" stroke="currentColor" stroke-width="1.8">
                    <circle cx="9" cy="9" r="6"/><path d="M15 15l-3.5-3.5"/>
                </svg>
                <input type="text" class="search-input" id="campaignSearch"
                       placeholder="Search campaigns…" aria-label="Search campaigns">
            </div>

            <!-- Status filter -->
            <div class="filter-group">
                <span class="filter-label-icon">🎯</span>
                <select class="filter-select" id="statusFilter" aria-label="Filter by status">
                    <option value="">All Statuses</option>
                    <option value="Active">Active</option>
                    <option value="Planned">Planned</option>
                    <option value="Completed">Completed</option>
                </select>
                <span class="filter-arrow">▾</span>
            </div>

            <!-- Type filter -->
            <div class="filter-group">
                <span class="filter-label-icon">📌</span>
                <select class="filter-select" id="typeFilter" aria-label="Filter by type">
                    <option value="">All Types</option>
                    <option value="Email">Email</option>
                    <option value="Ads">Ads</option>
                    <option value="Social Media">Social Media</option>
                </select>
                <span class="filter-arrow">▾</span>
            </div>

            <div class="toolbar-count" id="toolbarCount">
                <span id="visibleCount"><%= totalCampaigns %></span> / <%= totalCampaigns %>
                campaign<%= totalCampaigns != 1 ? "s" : "" %>
            </div>
        </div>

        <!-- Table card -->
        <div class="card fade-up">
            <div class="card-header">
                <h3>📋 All Campaigns</h3>
                <a href="<%= ctx %>/addCampaign" class="btn btn-primary btn-sm" id="addCampaignHeaderBtn">➕ Add</a>
            </div>

            <% if (campaigns == null || campaigns.isEmpty()) { %>
            <div class="empty-state">
                <div class="empty-icon">📭</div>
                <h3>No campaigns yet</h3>
                <p>Create your first campaign to start tracking your marketing efforts and measuring ROI.</p>
                <a href="<%= ctx %>/addCampaign" class="btn btn-primary" id="emptyAddCampaignBtn">➕ Create Campaign</a>
            </div>
            <% } else { %>
            <div class="table-wrapper">
                <table id="campaignTable">
                    <thead>
                        <tr>
                            <th style="width:42px;">#</th>
                            <th class="sortable">Campaign</th>
                            <th>Type</th>
                            <th class="sortable">Status</th>
                            <th class="sortable" style="text-align:right;">Budget (₹)</th>
                            <th style="text-align:center;">🎯 Leads</th>
                            <th>Start</th>
                            <th>End</th>
                            <th style="width:160px;">Actions</th>
                        </tr>
                    </thead>
                    <tbody id="campaignTbody">
                    <% int rowNum = 1; for (Campaign c : campaigns) {
                           String statusClass = "badge-planned";
                           if ("Active".equalsIgnoreCase(c.getStatus()))         statusClass = "badge-active";
                           else if ("Completed".equalsIgnoreCase(c.getStatus())) statusClass = "badge-completed";
                           String safeName = c.getName().replace("'", "\\'");
                           String rowStyle = "";
                           if ("Active".equalsIgnoreCase(c.getStatus()))         rowStyle = "Active";
                           else if ("Planned".equalsIgnoreCase(c.getStatus()))   rowStyle = "Planned";
                           else if ("Completed".equalsIgnoreCase(c.getStatus())) rowStyle = "Completed";
                    %>
                        <tr class="camp-row"
                            data-name="<%= c.getName().toLowerCase() %>"
                            data-status="<%= c.getStatus() %>"
                            data-type="<%= c.getType() %>"
                            data-status="<%= rowStyle %>">
                            <td class="text-muted text-xs num" style="text-align:center;"><%= rowNum++ %></td>
                            <td>
                                <div class="col-name"><%= c.getName() %></div>
                                <% if (c.getDescription() != null && !c.getDescription().isEmpty()) {
                                       String desc = c.getDescription();
                                       if (desc.length() > 58) desc = desc.substring(0, 58) + "…";
                                %>
                                <small class="text-muted"><%= desc %></small>
                                <% } %>
                            </td>
                            <td><span class="type-pill"><%= c.getType() %></span></td>
                            <td><span class="badge <%= statusClass %>"><%= c.getStatus() %></span></td>
                            <td style="text-align:right;font-weight:700;font-family:'Outfit',sans-serif;font-variant-numeric:tabular-nums;">
                                ₹<%= String.format("%,.2f", c.getBudget()) %>
                            </td>
                            <td style="text-align:center;font-weight:800;font-family:'Outfit',sans-serif;color:var(--teal-dark);">
                                <%= c.getLeads() %>
                            </td>
                            <td class="text-sm text-muted"><%= c.getStartDate() %></td>
                            <td class="text-sm text-muted"><%= c.getEndDate() %></td>
                            <td>
                                <div class="actions-cell">
                                    <a href="<%= ctx %>/tasks?campaignId=<%= c.getId() %>"
                                       class="btn btn-secondary btn-sm" title="View Tasks"
                                       id="tasksBtn_<%= c.getId() %>">🗂 Tasks</a>
                                    <a href="<%= ctx %>/editCampaign?id=<%= c.getId() %>"
                                       class="btn btn-warning btn-sm" title="Edit"
                                       id="editBtn_<%= c.getId() %>">✏️</a>
                                    <a href="<%= ctx %>/deleteCampaign?id=<%= c.getId() %>"
                                       class="btn btn-danger btn-sm" title="Delete"
                                       id="delBtn_<%= c.getId() %>"
                                       onclick="return confirmDel('<%= safeName %>')">🗑</a>
                                </div>
                            </td>
                        </tr>
                    <% } %>
                    </tbody>
                </table>
            </div>

            <!-- No results -->
            <div id="noResults" class="empty-state" style="display:none;padding:40px 20px;">
                <div class="empty-icon" style="font-size:2.5rem;">🔍</div>
                <h3 style="font-size:1rem;">No matches found</h3>
                <p>Try adjusting your filters or search term.</p>
            </div>

            <% } %>
        </div>

    </main>
</div>

<div class="toast-container" id="toastContainer"></div>

<script>
function confirmDel(name) {
    return confirm('Delete "' + name + '" and all its tasks?\n\nThis cannot be undone.');
}

/* Live filter */
(function() {
    var search  = document.getElementById('campaignSearch');
    var byStatus= document.getElementById('statusFilter');
    var byType  = document.getElementById('typeFilter');
    var tbody   = document.getElementById('campaignTbody');
    var noRes   = document.getElementById('noResults');
    var countEl = document.getElementById('visibleCount');
    if (!tbody) return;

    function run() {
        var q  = search  ? search.value.toLowerCase() : '';
        var st = byStatus? byStatus.value : '';
        var ty = byType  ? byType.value   : '';
        var n  = 0;
        tbody.querySelectorAll('.camp-row').forEach(function(row) {
            var ok = row.getAttribute('data-name').includes(q)
                  && (!st || row.getAttribute('data-status') === st)
                  && (!ty || row.getAttribute('data-type')   === ty);
            row.style.display = ok ? '' : 'none';
            if (ok) n++;
        });
        if (countEl) countEl.textContent = n;
        if (noRes)   noRes.style.display = n === 0 ? 'block' : 'none';
    }

    if (search)  search.addEventListener('input',  run);
    if (byStatus)byStatus.addEventListener('change', run);
    if (byType)  byType.addEventListener('change', run);
})();

/* Toasts */
(function() {
    var p = new URLSearchParams(window.location.search);
    var c = document.getElementById('toastContainer'); if (!c) return;
    function toast(msg, type) {
        var t = document.createElement('div');
        t.className = 'toast ' + (type || 'info');
        t.innerHTML = '<span>' + msg + '</span>';
        c.appendChild(t);
        setTimeout(function() {
            t.style.animation = 'toast-out 0.3s forwards';
            setTimeout(function() { t.remove(); }, 300);
        }, 3200);
    }
    if (p.get('saved')   === '1') toast('Campaign saved! ✅', 'success');
    if (p.get('deleted') === '1') toast('Campaign deleted.', 'info');
})();
</script>

</body>
</html>