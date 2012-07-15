/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package org.dspace.app.webui.servlet;

import java.io.IOException;
import java.sql.SQLException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import org.apache.log4j.Logger;
import org.dspace.app.webui.util.JSPManager;
import org.dspace.authenticate.AuthenticationManager;
import org.dspace.authenticate.AuthenticationMethod;
import org.dspace.authorize.AuthorizeException;
import org.dspace.core.Context;
import org.dspace.core.LogManager;
import org.dspace.eperson.EPerson;
import org.jasig.cas.client.authentication.AttributePrincipal;
import org.jasig.cas.client.validation.Assertion;
import org.jasig.cas.client.validation.Cas20ProxyTicketValidator;
import org.jasig.cas.client.validation.TicketValidationException;

/**
 *
 * @author LuckyMan
 */
public class CASServlet extends DSpaceServlet{
    private static Logger log = Logger.getLogger(CASServlet.class);
      protected void doDSGet(Context context, HttpServletRequest request,
            HttpServletResponse response) throws ServletException, IOException,
            SQLException, AuthorizeException
    {
        // Simply forward to the plain form
      //  JSPManager.showJSP(request, response, "/login/password.jsp");
        doPost(request, response);
    }
      
      protected void doDSPost(Context context, HttpServletRequest request,
            HttpServletResponse response) throws ServletException, IOException,
            SQLException, AuthorizeException
    {  
       
        String jsp = null;
        String ticket = request.getParameter("ticket");
        AttributePrincipal principal = null;
        String casServerUrl = "https://logon.vnpt.com.vn/cas/";
        Cas20ProxyTicketValidator sv = new Cas20ProxyTicketValidator(casServerUrl);
        sv.setAcceptAnyProxy(true);
        try {
            String legacyServerServiceUrl = "http://localhost:8080";
            Assertion a = sv.validate(ticket, legacyServerServiceUrl);
            principal = a.getPrincipal();
            System.out.println("user name:" + principal.getName());
            
                EPerson eperson = null;
                try
                {
                    String vnptEmail = principal.getName().toLowerCase()+"@vnpt.vn";
                    eperson = EPerson.findByEmail(context, vnptEmail);
                }
                catch (SQLException e)
                {
                	log.error("cas findByEmail failed");
                	log.error(e.getStackTrace());
                }
                if (eperson.getRequireCertificate())
                    {
                        // they must use a certificate
                        jsp = "/error/require-certificate.jsp";
                        JSPManager.showJSP(request, response, jsp);
                    }
                    else if (!eperson.canLogIn())
                        jsp = "/login/incorrect.jsp";
                        JSPManager.showJSP(request, response, jsp);

                // Logged in OK.

                HttpSession session = request.getSession(false);
                if(session!=null){
                	session.setAttribute("loginType", "CAS");
                }
                context.setCurrentUser(eperson);
                log.info(LogManager.getHeader(context, "authenticate", "type=CAS"));
                
        } catch (TicketValidationException e) {
            e.printStackTrace(); // bad style, but only for demonstration purpose.
        }
    }
}
