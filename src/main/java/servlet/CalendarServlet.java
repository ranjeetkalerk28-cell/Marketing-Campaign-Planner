package servlet;

import dao.TaskDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.time.YearMonth;
import java.util.List;
import java.util.Map;

/**
 * Controller for the Daily Tasks Calendar.
 *  GET /calendar[?month=YYYY-MM]  → daily-calendar.jsp
 */
@WebServlet("/calendar")
public class CalendarServlet extends HttpServlet {

    private final TaskDAO taskDAO = new TaskDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // ── Resolve the requested month (default = current month) ────
        String monthParam = req.getParameter("month"); // "YYYY-MM"
        YearMonth ym;
        try {
            ym = (monthParam != null && !monthParam.isEmpty())
                    ? YearMonth.parse(monthParam)
                    : YearMonth.now();
        } catch (Exception e) {
            ym = YearMonth.now();
        }

        int year  = ym.getYear();
        int month = ym.getMonthValue();

        // ── Prev / Next month strings for nav links ──────────────────
        req.setAttribute("year",      year);
        req.setAttribute("month",     month);
        req.setAttribute("yearMonth", ym.toString());
        req.setAttribute("prevMonth", ym.minusMonths(1).toString());
        req.setAttribute("nextMonth", ym.plusMonths(1).toString());

        try {
            List<Map<String, Object>> tasks = taskDAO.getTasksForMonth(year, month);
            req.setAttribute("calTasks", tasks);
            req.getRequestDispatcher("/daily-calendar.jsp").forward(req, resp);
        } catch (Exception e) {
            throw new ServletException("CalendarServlet error: " + e.getMessage(), e);
        }
    }
}
