<%@ page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8" %>
<%@ page import="model.Campaign" %>
<%
    Campaign campaign = (Campaign) request.getAttribute("campaign");
    String   ctx      = request.getContextPath();
    if (campaign == null) { response.sendRedirect(ctx + "/campaigns"); return; }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add Task — Marketing Campaign Planner</title>
    <meta name="description" content="Add a new task to the campaign.">
    <link rel="stylesheet" href="<%= ctx %>/css/style.css">
</head>
<body>

<%@ include file="/WEB-INF/includes/nav.jsp" %>

<div class="main-content">

    <header class="page-header">
        <div class="page-header-left">
            <h1>Add Task</h1>
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
            <span>Add Task</span>
        </div>

        <div class="card fade-up" style="max-width:780px;">
            <div class="card-header">
                <h3>📝 Task Details</h3>
                <span class="chip">New Task</span>
            </div>
            <div class="card-body">
                <form action="<%= ctx %>/addTask" method="post" id="addTaskForm" novalidate>
                    <input type="hidden" name="campaignId" value="<%= campaign.getId() %>">

                    <div class="form-grid">

                        <!-- Title -->
                        <div class="form-group span-2">
                            <label for="title">Task Title <span class="required">*</span></label>
                            <input type="text" id="title" name="title"
                                   placeholder="e.g. Design email template"
                                   required maxlength="100" autocomplete="off">
                        </div>

                        <div class="form-divider"></div>

                        <!-- Type -->
                        <div class="form-group">
                            <label for="type">Task Type <span class="required">*</span></label>
                            <select id="type" name="type" required>
                                <option value="" disabled selected>— Select type —</option>
                                <option value="Design">🎨 Design</option>
                                <option value="Content">✍️ Content</option>
                                <option value="Launch">🚀 Launch</option>
                                <option value="Research">🔍 Research</option>
                                <option value="Analysis">📊 Analysis</option>
                                <option value="Outreach">📞 Outreach</option>
                                <option value="Other">📌 Other</option>
                            </select>
                        </div>

                        <!-- Status -->
                        <div class="form-group">
                            <label for="status">Status <span class="required">*</span></label>
                            <select id="status" name="status" required>
                                <option value="Pending" selected>⏳ Pending</option>
                                <option value="In Progress">🔄 In Progress</option>
                                <option value="Completed">✅ Completed</option>
                            </select>
                        </div>

                        <!-- Deadline -->
                        <div class="form-group">
                            <label for="deadline">Deadline <span class="required">*</span></label>
                            <input type="date" id="deadline" name="deadline" required>
                        </div>

                        <!-- Cost -->
                        <div class="form-group">
                            <label for="cost">Task Cost (₹) <span class="required">*</span></label>
                            <input type="number" id="cost" name="cost"
                                   placeholder="0.00" min="0" step="0.01" required>
                            <span class="form-hint" id="costHint"></span>
                        </div>

                        <div class="form-divider"></div>

                        <!-- Leads Generated -->
                        <div class="form-group span-2">
                            <label for="leadsGenerated">Leads Generated</label>
                            <input type="number" id="leadsGenerated" name="leadsGenerated"
                                   placeholder="0" min="0" value="0">
                            <span class="form-hint">
                                Number of leads attributed to this task. Saving updates the campaign's total lead count and CPL automatically.
                            </span>
                        </div>

                    </div>

                    <div class="form-actions" style="margin-top:28px;">
                        <button type="submit" class="btn btn-primary" id="addTaskSubmitBtn">✅ Add Task</button>
                        <a href="<%= ctx %>/tasks?campaignId=<%= campaign.getId() %>"
                           class="btn btn-outline" id="cancelAddTaskBtn">Cancel</a>
                    </div>

                </form>
            </div>
        </div>

    </main>
</div>

<script>
(function() {
    var form = document.getElementById('addTaskForm');
    var submitBtn = document.getElementById('addTaskSubmitBtn');
    var costInput = document.getElementById('cost');
    var costHint  = document.getElementById('costHint');

    costInput.addEventListener('input', function() {
        var v = parseFloat(this.value);
        costHint.textContent = !isNaN(v) && v >= 0
            ? '≈ ₹' + v.toLocaleString('en-IN', { maximumFractionDigits: 2 })
            : '';
    });

    form.addEventListener('submit', function() {
        submitBtn.classList.add('loading');
        submitBtn.disabled = true;
    });
})();
</script>

</body>
</html>
