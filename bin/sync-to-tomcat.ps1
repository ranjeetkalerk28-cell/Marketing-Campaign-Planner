# sync-to-tomcat.ps1
# Copies all updated webapp files from src/main/webapp to target (Tomcat exploded WAR).
# Run after editing JSP/CSS files to see changes without a full Maven rebuild.

$src = "src\main\webapp"
$dst = "target\MarketingCampaignPlanner"

Write-Host "Syncing webapp files to Tomcat target..." -ForegroundColor Cyan

# CSS
Copy-Item "$src\css\style.css" "$dst\css\style.css" -Force

# JSP pages
foreach ($f in @("index.jsp","dashboard.jsp","campaign-list.jsp","add-campaign.jsp","edit-campaign.jsp","add-task.jsp","edit-task.jsp","task-list.jsp")) {
    Copy-Item "$src\$f" "$dst\$f" -Force
}

# Nav include
$navDir = "$dst\WEB-INF\includes"
if (!(Test-Path $navDir)) { New-Item -ItemType Directory -Path $navDir | Out-Null }
Copy-Item "$src\WEB-INF\includes\nav.jsp" "$navDir\nav.jsp" -Force

Write-Host "Done! Refresh your browser (Ctrl+Shift+R for hard reload)." -ForegroundColor Green
