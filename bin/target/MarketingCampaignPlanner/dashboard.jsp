<%@ page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8" %>
<%@ page import="java.util.Map" %>
<%
    Map<String, Object> stats = (Map<String, Object>) request.getAttribute("stats");
    int    total       = stats != null ? (int)    stats.getOrDefault("total",       0) : 0;
    int    active      = stats != null ? (int)    stats.getOrDefault("active",      0) : 0;
    int    completed   = stats != null ? (int)    stats.getOrDefault("completed",   0) : 0;
    int    planned     = stats != null ? (int)    stats.getOrDefault("planned",     0) : 0;
    double totalBudget = stats != null ? (double) stats.getOrDefault("totalBudget", 0.0) : 0.0;
    int    totalLeads  = stats != null ? (int)    stats.getOrDefault("totalLeads",  0) : 0;
    double cpl         = stats != null ? (double) stats.getOrDefault("cpl",         0.0) : 0.0;
    String ctx = request.getContextPath();

    int maxStat    = Math.max(1, total);
    int wActive    = total > 0 ? Math.round(100f * active    / maxStat) : 0;
    int wCompleted = total > 0 ? Math.round(100f * completed / maxStat) : 0;
    int wPlanned   = total > 0 ? Math.round(100f * planned   / maxStat) : 0;
    int completionPct = total > 0 ? Math.round(100f * completed / total) : 0;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard — Marketing Campaign Planner</title>
    <meta name="description" content="Overview of all marketing campaigns, tasks, and key performance metrics.">
    <link rel="stylesheet" href="<%= ctx %>/css/style.css">
</head>
<body>

<%@ include file="/WEB-INF/includes/nav.jsp" %>

<div class="main-content">

    <header class="page-header">
        <div class="page-header-left">
            <h1>Dashboard</h1>
            <p>Welcome back — here's your campaign overview</p>
        </div>
        <div class="page-header-right">
            <a href="<%= ctx %>/campaigns" class="btn btn-outline btn-sm" id="viewAllBtn">📋 All Campaigns</a>
            <a href="<%= ctx %>/addCampaign" class="btn btn-primary" id="dashNewCampaignBtn">➕ New Campaign</a>
        </div>
    </header>

    <main class="content-area">

        <!-- Section label -->
        <div class="section-header">
            <span class="section-title">Performance Overview</span>
            <div class="section-line"></div>
        </div>

        <!-- ── Stat Cards ────────────────────────────────────── -->
        <div class="stats-grid stagger">

            <div class="stat-card indigo fade-up" data-icon="📁">
                <div class="stat-top">
                    <div class="stat-icon-pill">📁</div>
                    <span class="stat-trend">All</span>
                </div>
                <div class="stat-body">
                    <div class="stat-value" data-count="<%= total %>">0</div>
                    <div class="stat-label">Total Campaigns</div>
                </div>
                <div class="stat-progress">
                    <div class="stat-progress-bar">
                        <div class="stat-progress-fill" style="width:0%;" data-w="100"></div>
                    </div>
                    <div class="stat-progress-label">100% of total</div>
                </div>
            </div>

            <div class="stat-card green fade-up" data-icon="🚀">
                <div class="stat-top">
                    <div class="stat-icon-pill">🚀</div>
                    <span class="stat-trend"><%= total > 0 ? wActive : 0 %>%</span>
                </div>
                <div class="stat-body">
                    <div class="stat-value" data-count="<%= active %>">0</div>
                    <div class="stat-label">Active Campaigns</div>
                </div>
                <div class="stat-progress">
                    <div class="stat-progress-bar">
                        <div class="stat-progress-fill" style="width:0%;background:linear-gradient(90deg,var(--success),var(--teal));" data-w="<%= wActive %>"></div>
                    </div>
                    <div class="stat-progress-label"><%= wActive %>% of total</div>
                </div>
            </div>

            <div class="stat-card purple fade-up" data-icon="✅">
                <div class="stat-top">
                    <div class="stat-icon-pill">✅</div>
                    <span class="stat-trend"><%= completionPct %>%</span>
                </div>
                <div class="stat-body">
                    <div class="stat-value" data-count="<%= completed %>">0</div>
                    <div class="stat-label">Completed</div>
                </div>
                <div class="stat-progress">
                    <div class="stat-progress-bar">
                        <div class="stat-progress-fill" style="width:0%;background:linear-gradient(90deg,var(--secondary),var(--rose));" data-w="<%= wCompleted %>"></div>
                    </div>
                    <div class="stat-progress-label"><%= wCompleted %>% of total</div>
                </div>
            </div>

            <div class="stat-card amber fade-up" data-icon="📅">
                <div class="stat-top">
                    <div class="stat-icon-pill">📅</div>
                    <span class="stat-trend"><%= wPlanned %>%</span>
                </div>
                <div class="stat-body">
                    <div class="stat-value" data-count="<%= planned %>">0</div>
                    <div class="stat-label">Planned</div>
                </div>
                <div class="stat-progress">
                    <div class="stat-progress-bar">
                        <div class="stat-progress-fill" style="width:0%;background:linear-gradient(90deg,var(--warning),var(--amber));" data-w="<%= wPlanned %>"></div>
                    </div>
                    <div class="stat-progress-label"><%= wPlanned %>% of total</div>
                </div>
            </div>

            <div class="stat-card teal fade-up" data-icon="🎯">
                <div class="stat-top">
                    <div class="stat-icon-pill">🎯</div>
                    <span class="stat-trend">Leads</span>
                </div>
                <div class="stat-body">
                    <div class="stat-value" data-count="<%= totalLeads %>">0</div>
                    <div class="stat-label">Total Leads Generated</div>
                </div>
                <div class="stat-progress">
                    <div class="stat-progress-bar">
                        <div class="stat-progress-fill" style="width:0%;background:linear-gradient(90deg,var(--teal),var(--info));" data-w="<%= totalLeads > 0 ? 78 : 0 %>"></div>
                    </div>
                    <div class="stat-progress-label">Across all campaigns</div>
                </div>
            </div>

            <div class="stat-card red fade-up" data-icon="💰">
                <div class="stat-top">
                    <div class="stat-icon-pill">💰</div>
                    <span class="stat-trend">Budget</span>
                </div>
                <div class="stat-body">
                    <div class="stat-value num" style="font-size:1.55rem;">₹<%= String.format("%,.0f", totalBudget) %></div>
                    <div class="stat-label">Total Budget Allocated</div>
                </div>
                <div class="stat-progress">
                    <div class="stat-progress-bar">
                        <div class="stat-progress-fill" style="width:0%;background:linear-gradient(90deg,var(--danger),var(--rose));" data-w="<%= totalBudget > 0 ? 85 : 0 %>"></div>
                    </div>
                    <div class="stat-progress-label">All campaigns combined</div>
                </div>
            </div>

        </div>

        <!-- ── CPL Banner ──────────────────────────────────── -->
        <div class="cpl-banner section-gap fade-up" style="animation-delay:0.28s;">
            <div class="cpl-banner-grid"></div>

            <div class="cpl-left">
                <div class="cpl-eyebrow">Cost Per Lead</div>
                <div class="cpl-value">
                    ₹<%= totalLeads > 0 ? String.format("%,.2f", cpl) : "—" %>
                </div>
                <div class="cpl-formula">
                    CPL = Total Budget ÷ Total Leads
                    <% if (totalLeads == 0) { %>
                    &nbsp;<em>(no leads recorded yet)</em>
                    <% } %>
                </div>
            </div>

            <div class="cpl-divider"></div>

            <div class="cpl-right">
                <div class="cpl-stats">
                    <div class="cpl-stat">
                        <div class="cpl-stat-label">Total Budget</div>
                        <div class="cpl-stat-val">₹<%= String.format("%,.0f", totalBudget) %></div>
                    </div>
                    <div class="cpl-stat">
                        <div class="cpl-stat-label">Total Leads</div>
                        <div class="cpl-stat-val"><%= totalLeads %></div>
                    </div>
                    <div class="cpl-stat">
                        <div class="cpl-stat-label">Completion</div>
                        <div class="cpl-stat-val"><%= completionPct %>%</div>
                    </div>
                </div>
            </div>
        </div>

        <!-- ── Quick Actions ───────────────────────────────── -->
        <div class="section-header" style="margin-top:6px;">
            <span class="section-title">Quick Actions</span>
            <div class="section-line"></div>
        </div>

        <div class="card fade-up" style="animation-delay:0.36s;">
            <div class="card-body quick-actions">
                <a href="<%= ctx %>/campaigns"   class="btn btn-primary"   id="qaCampaigns">📋 View All Campaigns</a>
                <a href="<%= ctx %>/addCampaign" class="btn btn-success"   id="qaAddCampaign">➕ Create Campaign</a>
                <% if (active > 0) { %>
                <a href="<%= ctx %>/campaigns"   class="btn btn-teal"      id="qaActive">🚀 <%= active %> Active</a>
                <% } %>
                <% if (planned > 0) { %>
                <a href="<%= ctx %>/campaigns"   class="btn btn-outline"   id="qaPlanned">📅 <%= planned %> Planned</a>
                <% } %>
            </div>
        </div>

    </main>
</div>

<div class="toast-container" id="toastContainer"></div>

<script>
/* ── Animate counter ── */
function countUp(el, target, ms) {
    if (target === 0) return;
    var step = 16, inc = target / (ms / step), cur = 0;
    var t = setInterval(function() {
        cur += inc;
        if (cur >= target) { cur = target; clearInterval(t); }
        el.textContent = Math.round(cur);
    }, step);
}

/* ── Reveal progress bars ── */
function revealBars() {
    document.querySelectorAll('.stat-progress-fill[data-w]').forEach(function(bar) {
        setTimeout(function() { bar.style.width = bar.getAttribute('data-w') + '%'; }, 350);
    });
}

window.addEventListener('DOMContentLoaded', function() {
    document.querySelectorAll('.stat-value[data-count]').forEach(function(el) {
        countUp(el, parseInt(el.getAttribute('data-count'), 10) || 0, 950);
    });
    revealBars();

    /* Toasts */
    var p = new URLSearchParams(window.location.search);
    if (p.get('saved')   === '1') toast('Campaign saved! ✅', 'success');
    if (p.get('deleted') === '1') toast('Campaign deleted.', 'info');

    /* Loading state on nav buttons */
    document.querySelectorAll('a.btn').forEach(function(b) {
        b.addEventListener('click', function() {
            this.classList.add('loading');
            setTimeout(function() { b.classList.remove('loading'); }, 6000);
        });
    });
});

function toast(msg, type) {
    var c = document.getElementById('toastContainer'); if (!c) return;
    var t = document.createElement('div');
    t.className = 'toast ' + (type || 'info');
    t.innerHTML = '<span>' + msg + '</span>';
    c.appendChild(t);
    setTimeout(function() {
        t.style.animation = 'toast-out 0.3s forwards';
        setTimeout(function() { t.remove(); }, 300);
    }, 3500);
}
</script>

</body>
</html>
