/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package org.dspace.app.webui.servlet;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Locale;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.jsp.jstl.core.Config;
import org.apache.log4j.Logger;
import org.dspace.app.webui.util.Authenticate;
import org.dspace.app.webui.util.JSPManager;
import org.dspace.authenticate.AuthenticationManager;
import org.dspace.authenticate.AuthenticationMethod;
import org.dspace.authorize.AuthorizeException;
import org.dspace.core.Context;
import org.dspace.core.I18nUtil;
import org.dspace.core.LogManager;
import org.dspace.eperson.EPerson;
import org.dspace.storage.rdbms.DatabaseManager;
import org.jasig.cas.client.authentication.AttributePrincipal;
import org.jasig.cas.client.validation.Assertion;
import org.jasig.cas.client.validation.Cas20ProxyTicketValidator;
import org.jasig.cas.client.validation.TicketValidationException;

/**
 *
 * @author LuckyMan
 */
public class CASServlet extends DSpaceServlet {

    private static Logger log = Logger.getLogger(CASServlet.class);

    protected void doDSGet(Context context, HttpServletRequest request,
            HttpServletResponse response) throws ServletException, IOException,
            SQLException, AuthorizeException {
        // Simply forward to the plain form
        //  JSPManager.showJSP(request, response, "/login/password.jsp");
        doDSPost(context, request, response);
    }

    protected void doDSPost(Context context, HttpServletRequest request,
            HttpServletResponse response) throws ServletException, IOException,
            SQLException, AuthorizeException {

        String jsp = null;
        try {
            EPerson eperson = null;
            try {
                String name = request.getUserPrincipal().getName().toLowerCase();
                String vnptEmail = name + "@vnpt.vn";
                eperson = EPerson.findByEmail(context, vnptEmail);
                if (eperson == null) {
                    // TEMPORARILY turn off authorisation
                    // Register the new user automatically
                    context.setIgnoreAuthorization(true);
                    eperson = EPerson.create(context);
                    // use netid only but this implies that user has to manually update their profile
//                    eperson.setNetid(netid);

                    // if you wish to automatically extract further user details: email, first_name and last_name
                    //  enter your method here: e.g. query LDAP or RDBMS etc.
                        /*
                     * e.g. registerUser(netid); eperson.setEmail(email);
                     */
                    eperson.setFirstName(name);
                    eperson.setEmail(vnptEmail);
                    eperson.setLastName(name);
                    eperson.setCanLogIn(true);
                    eperson.setRequireCertificate(false);
                    AuthenticationManager.initEPerson(context, request, eperson);
                    eperson.update();
                    context.commit();
                    context.setIgnoreAuthorization(false);
                    
                    DatabaseManager.updateQuery(context,
                    "INSERT INTO EPersonGroup2EPerson (eperson_group_id,eperson_id) VALUES (15,?)",eperson.getID());
//                    context.setCurrentUser(eperson);
                }
            } catch (SQLException e) {
                log.error("cas findByEmail failed");
                log.error(e.getStackTrace());
            }
            if (eperson.getRequireCertificate()) {
                // they must use a certificate
                jsp = "/error/require-certificate.jsp";
                JSPManager.showJSP(request, response, jsp);
            } else if (!eperson.canLogIn()) {
                jsp = "/login/incorrect.jsp";
                JSPManager.showJSP(request, response, jsp);
            }
            // Logged in OK.
            context.setCurrentUser(eperson);
            Authenticate.loggedIn(context, request, context.getCurrentUser());
            log.info(LogManager.getHeader(context, "authenticate", "type=SSOAuthentication"));
            // Set the Locale according to user preferences
            Locale epersonLocale = I18nUtil.getEPersonLocale(context.getCurrentUser());
            context.setCurrentLocale(epersonLocale);
            Config.set(request.getSession(), Config.FMT_LOCALE, epersonLocale);

            log.info(LogManager.getHeader(context, "login", "type=explicit"));

            // resume previous request
            Authenticate.resumeInterruptedRequest(request, response);

            return;
        } catch (Exception e) {
            e.printStackTrace(); // bad style, but only for demonstration purpose.
        }
    }
}
