<%@ page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8" %>
<%-- Shared sidebar navigation --%>
<%
    String _path = request.getServletPath();
    String _ctx  = request.getContextPath();
%>

<button class="mob-menu-btn" id="mobMenuBtn" aria-label="Open menu">
    <svg width="20" height="20" viewBox="0 0 20 20" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round">
        <line x1="3" y1="5"  x2="17" y2="5"/>
        <line x1="3" y1="10" x2="17" y2="10"/>
        <line x1="3" y1="15" x2="17" y2="15"/>
    </svg>
</button>
<div class="sidebar-overlay" id="sidebarOverlay"></div>

<aside class="sidebar" id="sidebar">

    <!-- Brand -->
    <div class="sidebar-brand">
        <div class="brand-icon">
            <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <line x1="18" y1="20" x2="18" y2="10"/><line x1="12" y1="20" x2="12" y2="4"/><line x1="6" y1="20" x2="6" y2="14"/>
            </svg>
        </div>
        <div class="brand-text-wrap">
            <div class="brand-name">Campaign Planner</div>
            <span class="brand-sub">Marketing Suite</span>
        </div>
        <div class="brand-version">v1.0</div>
    </div>

    <nav class="sidebar-nav">

        <span class="nav-section-label">Overview</span>
        <a href="<%= _ctx %>/dashboard"
           class="nav-item <%= (_path.equals("/") || _path.equals("/dashboard")) ? "active" : "" %>">
            <span class="nav-icon-wrap">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/>
                    <polyline points="9 22 9 12 15 12 15 22"/>
                </svg>
            </span>
            <span>Dashboard</span>
        </a>

        <span class="nav-section-label">Campaigns</span>
        <a href="<%= _ctx %>/campaigns"
           class="nav-item <%= _path.equals("/campaigns") ? "active" : "" %>">
            <span class="nav-icon-wrap">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/>
                    <rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/>
                </svg>
            </span>
            <span>All Campaigns</span>
        </a>
        <a href="<%= _ctx %>/addCampaign"
           class="nav-item <%= _path.equals("/addCampaign") ? "active" : "" %>">
            <span class="nav-icon-wrap">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <circle cx="12" cy="12" r="10"/>
                    <line x1="12" y1="8" x2="12" y2="16"/>
                    <line x1="8"  y1="12" x2="16" y2="12"/>
                </svg>
            </span>
            <span>New Campaign</span>
        </a>

        <span class="nav-section-label">Tasks</span>
        <a href="<%= _ctx %>/todaysTasks"
           class="nav-item <%= _path.equals("/todaysTasks") ? "active" : "" %>">
            <span class="nav-icon-wrap">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <circle cx="12" cy="12" r="5"/>
                    <line x1="12" y1="1"  x2="12" y2="3"/>
                    <line x1="12" y1="21" x2="12" y2="23"/>
                    <line x1="4.22" y1="4.22" x2="5.64" y2="5.64"/>
                    <line x1="18.36" y1="18.36" x2="19.78" y2="19.78"/>
                    <line x1="1"  y1="12" x2="3"  y2="12"/>
                    <line x1="21" y1="12" x2="23" y2="12"/>
                    <line x1="4.22" y1="19.78" x2="5.64" y2="18.36"/>
                    <line x1="18.36" y1="5.64"  x2="19.78" y2="4.22"/>
                </svg>
            </span>
            <span>Today's Tasks</span>
        </a>
        <a href="<%= _ctx %>/allTasks"
           class="nav-item <%= _path.equals("/allTasks") ? "active" : "" %>">
            <span class="nav-icon-wrap">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <line x1="8" y1="6"  x2="21" y2="6"/>
                    <line x1="8" y1="12" x2="21" y2="12"/>
                    <line x1="8" y1="18" x2="21" y2="18"/>
                    <line x1="3" y1="6"  x2="3.01" y2="6"/>
                    <line x1="3" y1="12" x2="3.01" y2="12"/>
                    <line x1="3" y1="18" x2="3.01" y2="18"/>
                </svg>
            </span>
            <span>Browse Tasks</span>
        </a>

        <span class="nav-section-label">Calendar</span>
        <a href="<%= _ctx %>/calendar"
           class="nav-item <%= _path.equals("/calendar") ? "active" : "" %>">
            <span class="nav-icon-wrap">
                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <rect x="3" y="4" width="18" height="18" rx="2" ry="2"/>
                    <line x1="16" y1="2"  x2="16" y2="6"/>
                    <line x1="8"  y1="2"  x2="8"  y2="6"/>
                    <line x1="3"  y1="10" x2="21" y2="10"/>
                </svg>
            </span>
            <span>Tasks Calendar</span>
        </a>

    </nav>

    <div class="sidebar-footer">
        <div class="sidebar-footer-row">
            <div class="footer-label">
                <div class="status-dot"></div>
                System live
            </div>
            <span style="color:rgba(255,255,255,0.22);font-size:0.65rem;">Phase 1</span>
        </div>
    </div>
</aside>

<script>
(function() {
    var btn     = document.getElementById('mobMenuBtn');
    var sidebar = document.getElementById('sidebar');
    var overlay = document.getElementById('sidebarOverlay');
    function openMenu()  { sidebar.classList.add('open'); overlay.classList.add('open'); }
    function closeMenu() { sidebar.classList.remove('open'); overlay.classList.remove('open'); }
    if (btn)     btn.addEventListener('click', function() { sidebar.classList.contains('open') ? closeMenu() : openMenu(); });
    if (overlay) overlay.addEventListener('click', closeMenu);
})();
</script>
