<%@ page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8" %>
<%@ page import="model.Campaign" %>
<%
    Campaign c   = (Campaign) request.getAttribute("campaign");
    String   ctx = request.getContextPath();
    if (c == null) { response.sendRedirect(ctx + "/campaigns"); return; }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Campaign — Marketing Campaign Planner</title>
    <meta name="description" content="Edit an existing marketing campaign.">
    <link rel="stylesheet" href="<%= ctx %>/css/style.css">
</head>
<body>

<%@ include file="/WEB-INF/includes/nav.jsp" %>

<div class="main-content">

    <header class="page-header">
        <div class="page-header-left">
            <h1>Edit Campaign</h1>
            <p>Updating: "<%= c.getName() %>"</p>
        </div>
        <a href="<%= ctx %>/campaigns" class="btn btn-outline" id="backToListBtn">← Back to List</a>
    </header>

    <main class="content-area">

        <div class="breadcrumb">
            <a href="<%= ctx %>/dashboard">Dashboard</a>
            <span class="sep">›</span>
            <a href="<%= ctx %>/campaigns">Campaigns</a>
            <span class="sep">›</span>
            <span>Edit: <%= c.getName() %></span>
        </div>

        <div class="card fade-up" style="max-width:880px;">
            <div class="card-header">
                <h3>✏️ Edit Campaign Details</h3>
                <span class="chip text-muted">ID #<%= c.getId() %></span>
            </div>
            <div class="card-body">
                <form action="<%= ctx %>/editCampaign" method="post" id="editCampaignForm" novalidate>
                    <input type="hidden" name="id" value="<%= c.getId() %>">

                    <div class="form-grid">

                        <div class="form-group span-2">
                            <label for="name">Campaign Name <span class="required">*</span></label>
                            <input type="text" id="name" name="name"
                                   value="<%= c.getName() %>"
                                   required maxlength="100">
                        </div>

                        <div class="form-group span-2">
                            <label for="description">Description</label>
                            <textarea id="description" name="description"
                                      rows="3"><%= c.getDescription() != null ? c.getDescription() : "" %></textarea>
                        </div>

                        <div class="form-divider"></div>

                        <div class="form-group">
                            <label for="type">Campaign Type <span class="required">*</span></label>
                            <select id="type" name="type" required>
                                <option value="Email"        <%= "Email".equals(c.getType())        ? "selected" : "" %>>📧 Email</option>
                                <option value="Ads"          <%= "Ads".equals(c.getType())          ? "selected" : "" %>>📢 Ads</option>
                                <option value="Social Media" <%= "Social Media".equals(c.getType()) ? "selected" : "" %>>📱 Social Media</option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label for="status">Status <span class="required">*</span></label>
                            <select id="status" name="status" required>
                                <option value="Planned"   <%= "Planned".equals(c.getStatus())   ? "selected" : "" %>>📅 Planned</option>
                                <option value="Active"    <%= "Active".equals(c.getStatus())    ? "selected" : "" %>>🚀 Active</option>
                                <option value="Completed" <%= "Completed".equals(c.getStatus()) ? "selected" : "" %>>✅ Completed</option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label for="budget">Budget (₹) <span class="required">*</span></label>
                            <input type="number" id="budget" name="budget"
                                   value="<%= c.getBudget() %>"
                                   min="0" step="0.01" required>
                            <span class="form-hint" id="budgetHint">Current: ₹<%= String.format("%,.2f", c.getBudget()) %></span>
                        </div>

                        <div class="form-group">
                            <label style="color:var(--text-muted);font-weight:500;">Leads (auto-calculated)</label>
                            <input type="text" value="<%= c.getLeads() %> leads from tasks"
                                   disabled style="background:var(--border-light);color:var(--text-muted);">
                            <span class="form-hint">Updated automatically when task leads change.</span>
                        </div>

                        <div class="form-divider"></div>

                        <div class="form-group">
                            <label for="startDate">Start Date <span class="required">*</span></label>
                            <input type="date" id="startDate" name="startDate"
                                   value="<%= c.getStartDate() %>" required>
                        </div>

                        <div class="form-group">
                            <label for="endDate">End Date <span class="required">*</span></label>
                            <input type="date" id="endDate" name="endDate"
                                   value="<%= c.getEndDate() %>" required>
                            <span class="form-hint" id="dateHint" style="color:var(--danger);"></span>
                        </div>

                    </div>

                    <div class="form-actions" style="margin-top:28px;">
                        <button type="submit" class="btn btn-warning" id="saveBtn">💾 Save Changes</button>
                        <a href="<%= ctx %>/campaigns" class="btn btn-outline" id="cancelEditBtn">Cancel</a>
                    </div>

                </form>
            </div>
        </div>

    </main>
</div>

<script>
(function() {
    var form = document.getElementById('editCampaignForm');
    var saveBtn = document.getElementById('saveBtn');
    var startDate = document.getElementById('startDate');
    var endDate   = document.getElementById('endDate');
    var dateHint  = document.getElementById('dateHint');
    var budgetInput = document.getElementById('budget');
    var budgetHint  = document.getElementById('budgetHint');

    budgetInput.addEventListener('input', function() {
        var v = parseFloat(this.value);
        budgetHint.textContent = !isNaN(v) && v >= 0
            ? 'New value: ₹' + v.toLocaleString('en-IN', { maximumFractionDigits: 2 })
            : 'Current: ₹<%= String.format("%,.2f", c.getBudget()) %>';
    });

    function validateDates() {
        var s = startDate.value, e = endDate.value;
        if (s && e && e < s) {
            dateHint.textContent = '⚠ End date must be on or after start date.';
            endDate.style.borderColor = 'var(--danger)';
            return false;
        }
        dateHint.textContent = '';
        endDate.style.borderColor = '';
        return true;
    }

    startDate.addEventListener('change', validateDates);
    endDate.addEventListener('change', validateDates);
    validateDates();

    form.addEventListener('submit', function(e) {
        if (!validateDates()) { e.preventDefault(); return; }
        saveBtn.classList.add('loading');
        saveBtn.disabled = true;
    });
})();
</script>

</body>
</html>
