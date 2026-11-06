package servlet;

import dao.CampaignDAO;
import dao.TaskDAO;
import model.Campaign;
import model.Task;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.Date;
import java.util.List;

/**
 * Controller for Task-related URLs.
 * Handles: /tasks, /addTask, /editTask, /updateTask, /deleteTask, /quickUpdateTask
 */
@WebServlet(urlPatterns = {"/tasks", "/allTasks", "/addTask", "/editTask",
                           "/updateTask", "/deleteTask", "/quickUpdateTask",
                           "/todaysTasks"})
public class TaskServlet extends HttpServlet {

    private final TaskDAO     taskDAO     = new TaskDAO();
    private final CampaignDAO campaignDAO = new CampaignDAO();

    // ── GET ─────────────────────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String path = req.getServletPath();

        try {
            switch (path) {

                case "/tasks":
                    int campId = Integer.parseInt(req.getParameter("campaignId"));
                    List<Task> tasks = taskDAO.getTasksByCampaignId(campId);
                    Campaign campaign = campaignDAO.getCampaignById(campId);
                    req.setAttribute("tasks",    tasks);
                    req.setAttribute("campaign", campaign);
                    req.getRequestDispatcher("/task-list.jsp").forward(req, resp);
                    break;

                case "/allTasks":
                    req.setAttribute("allTasks", taskDAO.getAllTasksWithCampaign());
                    req.setAttribute("taskStats", taskDAO.getAllTaskStats());
                    req.getRequestDispatcher("/all-tasks.jsp").forward(req, resp);
                    break;

                case "/todaysTasks":
                    req.setAttribute("todaysTasks", taskDAO.getTodaysTasks());
                    req.getRequestDispatcher("/todays-tasks.jsp").forward(req, resp);
                    break;
                case "/addTask":
                    int addCampId = Integer.parseInt(req.getParameter("campaignId"));
                    Campaign addCampaign = campaignDAO.getCampaignById(addCampId);
                    req.setAttribute("campaign", addCampaign);
                    req.getRequestDispatcher("/add-task.jsp").forward(req, resp);
                    break;

                case "/editTask":
                    int taskId = Integer.parseInt(req.getParameter("id"));
                    Task task = taskDAO.getTaskById(taskId);
                    if (task == null) {
                        resp.sendRedirect(req.getContextPath() + "/campaigns");
                        return;
                    }
                    Campaign taskCampaign = campaignDAO.getCampaignById(task.getCampaignId());
                    req.setAttribute("task",     task);
                    req.setAttribute("campaign", taskCampaign);
                    req.getRequestDispatcher("/edit-task.jsp").forward(req, resp);
                    break;

                case "/deleteTask":
                    int delTaskId = Integer.parseInt(req.getParameter("id"));
                    int delCampId = taskDAO.getCampaignIdByTaskId(delTaskId);
                    taskDAO.deleteTask(delTaskId);
                    if (delCampId != -1) campaignDAO.updateLeads(delCampId);
                    resp.sendRedirect(req.getContextPath() + "/tasks?campaignId=" + delCampId);
                    break;

                default:
                    resp.sendRedirect(req.getContextPath() + "/campaigns");
            }
        } catch (Exception e) {
            throw new ServletException("TaskServlet GET error: " + e.getMessage(), e);
        }
    }

    // ── POST ────────────────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String path = req.getServletPath();

        try {
            if ("/addTask".equals(path)) {
                Task t = buildFromRequest(req);
                taskDAO.addTask(t);
                campaignDAO.updateLeads(t.getCampaignId());
                resp.sendRedirect(req.getContextPath() + "/tasks?campaignId=" + t.getCampaignId());

            } else if ("/updateTask".equals(path)) {
                Task t = buildFromRequest(req);
                t.setId(Integer.parseInt(req.getParameter("id")));
                taskDAO.updateTask(t);
                campaignDAO.updateLeads(t.getCampaignId());
                resp.sendRedirect(req.getContextPath() + "/tasks?campaignId=" + t.getCampaignId());

            } else if ("/quickUpdateTask".equals(path)) {
                // Inline quick-update: only status + leadsGenerated
                int taskId = Integer.parseInt(req.getParameter("id"));
                int campId = Integer.parseInt(req.getParameter("campaignId"));
                Task t = taskDAO.getTaskById(taskId);
                if (t != null) {
                    String newStatus = req.getParameter("status");
                    String leadsStr  = req.getParameter("leadsGenerated");
                    if (newStatus != null && !newStatus.isEmpty())  t.setStatus(newStatus);
                    if (leadsStr  != null && !leadsStr.isEmpty())   t.setLeadsGenerated(Integer.parseInt(leadsStr));
                    taskDAO.updateTask(t);
                    campaignDAO.updateLeads(campId);
                }
                resp.sendRedirect(req.getContextPath() + "/tasks?campaignId=" + campId);
            }
        } catch (Exception e) {
            throw new ServletException("TaskServlet POST error: " + e.getMessage(), e);
        }
    }

    // ── Helper ──────────────────────────────────────────────────
    private Task buildFromRequest(HttpServletRequest req) {
        Task t = new Task();
        t.setCampaignId    (Integer.parseInt(req.getParameter("campaignId")));
        t.setTitle         (req.getParameter("title"));
        t.setType          (req.getParameter("type"));
        t.setDeadline      (Date.valueOf(req.getParameter("deadline")));
        t.setCost          (Double.parseDouble(req.getParameter("cost")));
        t.setStatus        (req.getParameter("status"));
        String leads = req.getParameter("leadsGenerated");
        t.setLeadsGenerated(leads != null && !leads.isEmpty() ? Integer.parseInt(leads) : 0);
        return t;
    }
}
