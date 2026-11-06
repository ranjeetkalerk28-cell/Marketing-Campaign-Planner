package servlet;

import dao.CampaignDAO;
import model.Campaign;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.Date;
import java.util.List;
import java.util.Map;

/**
 * Controller for Campaign-related URLs.
 * Handles: /, /dashboard, /campaigns, /addCampaign, /editCampaign, /deleteCampaign
 */
@WebServlet(urlPatterns = {"/dashboard", "/campaigns",
                           "/addCampaign", "/editCampaign", "/deleteCampaign"})
public class CampaignServlet extends HttpServlet {

    private final CampaignDAO campaignDAO = new CampaignDAO();

    // ── GET ─────────────────────────────────────────────────────
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String path = req.getServletPath();

        try {
            switch (path) {

                case "/":
                case "/dashboard":
                    Map<String, Object> stats = campaignDAO.getDashboardStats();
                    req.setAttribute("stats", stats);
                    req.getRequestDispatcher("/dashboard.jsp").forward(req, resp);
                    break;

                case "/campaigns":
                    List<Campaign> campaigns = campaignDAO.getAllCampaigns();
                    req.setAttribute("campaigns", campaigns);
                    req.getRequestDispatcher("/campaign-list.jsp").forward(req, resp);
                    break;

                case "/addCampaign":
                    req.getRequestDispatcher("/add-campaign.jsp").forward(req, resp);
                    break;

                case "/editCampaign":
                    int editId = Integer.parseInt(req.getParameter("id"));
                    Campaign toEdit = campaignDAO.getCampaignById(editId);
                    if (toEdit == null) {
                        resp.sendRedirect(req.getContextPath() + "/campaigns");
                        return;
                    }
                    req.setAttribute("campaign", toEdit);
                    req.getRequestDispatcher("/edit-campaign.jsp").forward(req, resp);
                    break;

                case "/deleteCampaign":
                    int delId = Integer.parseInt(req.getParameter("id"));
                    campaignDAO.deleteCampaign(delId);
                    resp.sendRedirect(req.getContextPath() + "/campaigns");
                    break;

                default:
                    resp.sendRedirect(req.getContextPath() + "/dashboard");
                    break;
            }
        } catch (Exception e) {
            throw new ServletException("CampaignServlet GET error: " + e.getMessage(), e);
        }
    }

    // ── POST ────────────────────────────────────────────────────
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String path = req.getServletPath();

        try {
            if ("/addCampaign".equals(path)) {
                Campaign c = buildFromRequest(req);
                campaignDAO.insertCampaign(c);
                resp.sendRedirect(req.getContextPath() + "/campaigns");

            } else if ("/editCampaign".equals(path)) {
                Campaign c = buildFromRequest(req);
                c.setId(Integer.parseInt(req.getParameter("id")));
                campaignDAO.updateCampaign(c);
                resp.sendRedirect(req.getContextPath() + "/campaigns");
            }
        } catch (Exception e) {
            throw new ServletException("CampaignServlet POST error: " + e.getMessage(), e);
        }
    }

    // ── Helper ──────────────────────────────────────────────────
    private Campaign buildFromRequest(HttpServletRequest req) {
        Campaign c = new Campaign();
        c.setName       (req.getParameter("name"));
        c.setDescription(req.getParameter("description"));
        c.setStartDate  (Date.valueOf(req.getParameter("startDate")));
        c.setEndDate    (Date.valueOf(req.getParameter("endDate")));
        c.setBudget     (Double.parseDouble(req.getParameter("budget")));
        c.setType       (req.getParameter("type"));
        c.setStatus     (req.getParameter("status"));
        return c;
    }
}
