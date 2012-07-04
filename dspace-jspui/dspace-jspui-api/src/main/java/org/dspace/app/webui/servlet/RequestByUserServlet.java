/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.app.webui.servlet;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Calendar;
import java.util.Date;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.apache.log4j.Logger;
import org.dspace.app.webui.filter.RegisteredOnlyFilter;
import org.dspace.app.webui.util.JSPManager;
import org.dspace.authorize.AuthorizeException;
import org.dspace.core.Context;
import org.dspace.eperson.EPerson;
import org.dspace.request.UserRequests;
/**
 *
 * @author Linh
 */
public class RequestByUserServlet extends DSpaceServlet{
    private static Logger log = Logger.getLogger(RequestByUserServlet.class);

    protected void doDSGet(Context context, HttpServletRequest request,
            HttpServletResponse response) throws ServletException, IOException,
            SQLException, AuthorizeException
    {
        if(context.getCurrentUser()==null){
            RegisteredOnlyFilter ft=new RegisteredOnlyFilter();
            ft.doFilter(request, response, null);
        }
        JSPManager.showJSP(request, response, "/request/requestByUser.jsp");
    }
    protected void doDSPost(Context context, HttpServletRequest request,
            HttpServletResponse response) throws ServletException, IOException,
            SQLException, AuthorizeException
    {
        
           EPerson eperson=context.getCurrentUser(); 
           long epersonId=eperson.getID();
           String email=eperson.getEmail();
           String content=request.getParameter("content");
           Calendar cal=Calendar.getInstance();
           Date createDate=cal.getTime();
           
           UserRequests.create(context);
            JSPManager.showJSP(request, response, "/request/requestByUser.jsp");
    }
}
