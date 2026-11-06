<%@ page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8" %>
<%@ page import="model.Task" %>
<%@ page import="model.Campaign" %>
<%
    Task     task     = (Task)     request.getAttribute("task");
    Campaign campaign = (Campaign) request.getAttribute("campaign");
    String   ctx      = request.getContextPath();
    if (task == null || campaign == null) { response.sendRedirect(ctx + "/campaigns"); return; }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Task — Marketing Campaign Planner</title>
    <meta name="description" content="Edit task details.">
    <link rel="stylesheet" href="<%= ctx %>/css/style.css">
</head>
<body>

<%@ include file="/WEB-INF/includes/nav.jsp" %>

<div class="main-content">

    <header class="page-header">
        <div class="page-header-left">
            <h1>Edit Task</h1>
            <p>Campaign: <strong><%= campaign.getName() %></strong></p>
        </div>
        <a href="<%= ctx %>/tasks?campaignId=<%= campaign.getId() %>"
           class="btn btn-outline" id="backToTasksBtn">← Back to Tasks</a>
    </header>

    <main class="content-area">

        <div class="breadcrumb">
            <a href="<%= ctx %>/dashboard">Dashboard</a>
            <span class="sep">›</span>
            <a href="<%= ctx %>/campaigns">Campaigns</a>
            <span class="sep">›</span>
            <a href="<%= ctx %>/tasks?campaignId=<%= campaign.getId() %>"><%= campaign.getName() %></a>
            <span class="sep">›</span>
            <span>Edit Task</span>
        </div>

        <div class="card fade-up" style="max-width:780px;">
            <div class="card-header">
                <h3>✏️ Edit Task Details</h3>
                <span class="chip text-muted">Task ID #<%= task.getId() %></span>
            </div>
            <div class="card-body">
                <form action="<%= ctx %>/updateTask" method="post" id="editTaskForm" novalidate>
                    <input type="hidden" name="id"         value="<%= task.getId() %>">
                    <input type="hidden" name="campaignId" value="<%= campaign.getId() %>">

                    <div class="form-grid">

                        <!-- Title -->
                        <div class="form-group span-2">
                            <label for="title">Task Title <span class="required">*</span></label>
                            <input type="text" id="title" name="title"
                                   value="<%= task.getTitle() %>"
                                   required maxlength="100">
                        </div>

                        <div class="form-divider"></div>

                        <!-- Type -->
                        <div class="form-group">
                            <label for="type">Task Type <span class="required">*</span></label>
                            <select id="type" name="type" required>
                                <option value="Design"   <%= "Design".equals(task.getType())   ? "selected":"" %>>🎨 Design</option>
                                <option value="Content"  <%= "Content".equals(task.getType())  ? "selected":"" %>>✍️ Content</option>
                                <option value="Launch"   <%= "Launch".equals(task.getType())   ? "selected":"" %>>🚀 Launch</option>
                                <option value="Research" <%= "Research".equals(task.getType()) ? "selected":"" %>>🔍 Research</option>
                                <option value="Analysis" <%= "Analysis".equals(task.getType()) ? "selected":"" %>>📊 Analysis</option>
                                <option value="Outreach" <%= "Outreach".equals(task.getType()) ? "selected":"" %>>📞 Outreach</option>
                                <option value="Other"    <%= "Other".equals(task.getType())    ? "selected":"" %>>📌 Other</option>
                            </select>
                        </div>

                        <!-- Status -->
                        <div class="form-group">
                            <label for="status">Status <span class="required">*</span></label>
                            <select id="status" name="status" required>
                                <option value="Pending"     <%= "Pending".equalsIgnoreCase(task.getStatus())     ? "selected":"" %>>⏳ Pending</option>
                                <option value="In Progress" <%= "In Progress".equalsIgnoreCase(task.getStatus()) ? "selected":"" %>>🔄 In Progress</option>
                                <option value="Completed"   <%= "Completed".equalsIgnoreCase(task.getStatus())   ? "selected":"" %>>✅ Completed</option>
                            </select>
                        </div>

                        <!-- Deadline -->
                        <div class="form-group">
                            <label for="deadline">Deadline <span class="required">*</span></label>
                            <input type="date" id="deadline" name="deadline"
                                   value="<%= task.getDeadline() %>" required>
                        </div>

                        <!-- Cost -->
                        <div class="form-group">
                            <label for="cost">Task Cost (₹) <span class="required">*</span></label>
                            <input type="number" id="cost" name="cost"
                                   value="<%= task.getCost() %>"
                                   min="0" step="0.01" required>
                            <span class="form-hint" id="costHint">Current: ₹<%= String.format("%,.2f", task.getCost()) %></span>
                        </div>

                        <div class="form-divider"></div>

                        <!-- Leads Generated -->
                        <div class="form-group span-2">
                            <label for="leadsGenerated">Leads Generated</label>
                            <input type="number" id="leadsGenerated" name="leadsGenerated"
                                   value="<%= task.getLeadsGenerated() %>" min="0">
                            <span class="form-hint">
                                Updating this will automatically recalculate the campaign's total lead count and CPL.
                            </span>
                        </div>

                    </div>

                    <div class="form-actions" style="margin-top:28px;">
                        <button type="submit" class="btn btn-warning" id="saveTaskBtn">💾 Save Changes</button>
                        <a href="<%= ctx %>/tasks?campaignId=<%= campaign.getId() %>"
                           class="btn btn-outline" id="cancelEditTaskBtn">Cancel</a>
                    </div>

                </form>
            </div>
        </div>

    </main>
</div>

<script>
(function() {
    var form    = document.getElementById('editTaskForm');
    var saveBtn = document.getElementById('saveTaskBtn');
    var costInput = document.getElementById('cost');
    var costHint  = document.getElementById('costHint');

    costInput.addEventListener('input', function() {
        var v = parseFloat(this.value);
        costHint.textContent = !isNaN(v) && v >= 0
            ? 'New value: ₹' + v.toLocaleString('en-IN', { maximumFractionDigits: 2 })
            : 'Current: ₹<%= String.format("%,.2f", task.getCost()) %>';
    });

    form.addEventListener('submit', function() {
        saveBtn.classList.add('loading');
        saveBtn.disabled = true;
    });
})();
</script>

</body>
</html>
