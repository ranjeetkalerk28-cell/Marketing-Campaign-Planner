<%@ page pageEncoding="UTF-8" contentType="text/html;charset=UTF-8" %>
<%
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add Campaign — Marketing Campaign Planner</title>
    <meta name="description" content="Create a new marketing campaign.">
    <link rel="stylesheet" href="<%= ctx %>/css/style.css">
</head>
<body>

<%@ include file="/WEB-INF/includes/nav.jsp" %>

<div class="main-content">

    <header class="page-header">
        <div class="page-header-left">
            <h1>New Campaign</h1>
            <p>Fill in the details to launch a new campaign</p>
        </div>
        <div class="page-header-right">
            <a href="<%= ctx %>/campaigns" class="btn btn-outline" id="backToListBtn">← Back to List</a>
        </div>
    </header>

    <main class="content-area">

        <div class="breadcrumb">
            <a href="<%= ctx %>/dashboard">Dashboard</a>
            <span class="sep">›</span>
            <a href="<%= ctx %>/campaigns">Campaigns</a>
            <span class="sep">›</span>
            <span>Add Campaign</span>
        </div>

        <div class="card fade-up" style="max-width:900px;">
            <div class="card-header">
                <h3>📝 Campaign Details</h3>
                <span class="chip">New</span>
            </div>
            <div class="card-body">
                <form action="<%= ctx %>/addCampaign" method="post" id="addCampaignForm" novalidate>

                    <div class="form-grid">

                        <!-- Name -->
                        <div class="form-group span-2">
                            <label for="name">Campaign Name <span class="required">*</span></label>
                            <input type="text" id="name" name="name"
                                   placeholder="e.g. Spring Email Blast 2026"
                                   required maxlength="100" autocomplete="off">
                            <span class="form-hint" id="nameHint"></span>
                        </div>

                        <!-- Description -->
                        <div class="form-group span-2">
                            <label for="description">Description</label>
                            <textarea id="description" name="description"
                                      placeholder="Brief description of campaign goals and target audience…"
                                      rows="3"></textarea>
                        </div>

                        <div class="form-divider"></div>

                        <!-- Type -->
                        <div class="form-group">
                            <label for="type">Campaign Type <span class="required">*</span></label>
                            <select id="type" name="type" required>
                                <option value="" disabled selected>— Select type —</option>
                                <option value="Email">📧 Email</option>
                                <option value="Ads">📢 Ads</option>
                                <option value="Social Media">📱 Social Media</option>
                            </select>
                        </div>

                        <!-- Status -->
                        <div class="form-group">
                            <label for="status">Status <span class="required">*</span></label>
                            <select id="status" name="status" required>
                                <option value="" disabled selected>— Select status —</option>
                                <option value="Planned">📅 Planned</option>
                                <option value="Active">🚀 Active</option>
                                <option value="Completed">✅ Completed</option>
                            </select>
                        </div>

                        <!-- Budget -->
                        <div class="form-group">
                            <label for="budget">Budget (₹) <span class="required">*</span></label>
                            <input type="number" id="budget" name="budget"
                                   placeholder="0.00" min="0" step="0.01" required>
                            <span class="form-hint" id="budgetHint"></span>
                        </div>

                        <!-- Spacer -->
                        <div></div>

                        <div class="form-divider"></div>

                        <!-- Start Date -->
                        <div class="form-group">
                            <label for="startDate">Start Date <span class="required">*</span></label>
                            <input type="date" id="startDate" name="startDate" required>
                        </div>

                        <!-- End Date -->
                        <div class="form-group">
                            <label for="endDate">End Date <span class="required">*</span></label>
                            <input type="date" id="endDate" name="endDate" required>
                            <span class="form-hint" id="dateHint" style="color:var(--danger);"></span>
                        </div>

                    </div>

                    <div class="form-actions" style="margin-top:28px;">
                        <button type="submit" class="btn btn-primary" id="submitBtn">✅ Create Campaign</button>
                        <a href="<%= ctx %>/campaigns" class="btn btn-outline" id="cancelBtn">Cancel</a>
                    </div>

                </form>
            </div>
        </div>

    </main>
</div>

<script>
(function() {
    var form    = document.getElementById('addCampaignForm');
    var submitBtn = document.getElementById('submitBtn');
    var nameInput = document.getElementById('name');
    var budgetInput = document.getElementById('budget');
    var startDate = document.getElementById('startDate');
    var endDate   = document.getElementById('endDate');
    var dateHint  = document.getElementById('dateHint');
    var budgetHint= document.getElementById('budgetHint');

    /* Live character counter for name */
    nameInput.addEventListener('input', function() {
        var left = 100 - this.value.length;
        document.getElementById('nameHint').textContent = left <= 20 ? left + ' characters remaining' : '';
    });

    /* Live budget formatter */
    budgetInput.addEventListener('input', function() {
        var v = parseFloat(this.value);
        if (!isNaN(v) && v > 0) {
            budgetHint.textContent = '≈ ₹' + v.toLocaleString('en-IN', { maximumFractionDigits: 2 });
        } else {
            budgetHint.textContent = '';
        }
    });

    /* Live date validation */
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

    /* Submit */
    form.addEventListener('submit', function(e) {
        if (!validateDates()) { e.preventDefault(); return; }
        submitBtn.classList.add('loading');
        submitBtn.disabled = true;
    });
})();
</script>

</body>
</html>
