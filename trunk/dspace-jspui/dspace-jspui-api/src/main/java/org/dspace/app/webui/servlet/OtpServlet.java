/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package org.dspace.app.webui.servlet;

/**
 *
 * @author ThucLH
 */
import java.io.*;
import java.sql.SQLException;
import java.util.Date;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.apache.commons.fileupload.FileUploadBase.FileSizeLimitExceededException;

import org.apache.log4j.Logger;
import org.dspace.app.util.AuthorizeUtil;
import org.dspace.app.webui.servlet.DSpaceServlet;
import org.dspace.app.webui.util.FileUploadRequest;
import org.dspace.app.webui.util.JSPManager;
import org.dspace.app.webui.util.UIUtil;
import org.dspace.authorize.AuthorizeException;
import org.dspace.authorize.AuthorizeManager;
import org.dspace.content.*;
import org.dspace.core.ConfigurationManager;
import org.dspace.harvest.HarvestedCollection;
import org.dspace.core.Constants;
import org.dspace.core.Context;
import org.dspace.core.LogManager;
import org.dspace.eperson.EPerson;
import org.dspace.eperson.Group;

/**
 * Servlet for editing communities and collections, including deletion,
 * creation, and metadata editing
 *
 * @author Robert Tansley
 * @version $Revision: 6151 $
 */
public class OtpServlet extends DSpaceServlet {

    /**
     * Logger
     */
    private static Logger log = Logger.getLogger(CommentServlet.class);

    @Override
    protected void doDSGet(Context context, HttpServletRequest request,
            HttpServletResponse response) throws ServletException, IOException,
            SQLException, AuthorizeException {
        int item_id = UIUtil.getIntParameter(request, "item_id");
        String otp_content = request.getParameter("otp");
        Item item = Item.find(context, item_id);
        if (item_id == -1 || item == null) {
            response.setContentType("text/html");
            // Get the printwriter object from response to write the required json object to the output stream      
            PrintWriter out = response.getWriter();
            // Assuming your json object is **jsonObject**, perform the following, it will return your json object  
            out.print("Không tồn tại tài liệu!");
            out.flush();
//            response.sendRedirect(request.getContextPath());
        } else {
            Otp otp_obj = Otp.findByOtp(context, otp_content);
            if (otp_obj == null) {
                response.setContentType("text/html;charset=UTF-8");
                // Get the printwriter object from response to write the required json object to the output stream      
                PrintWriter out = response.getWriter();
                // Assuming your json object is **jsonObject**, perform the following, it will return your json object  
                out.print("Mã download không đúng!");
                out.flush();
            } else {
                otp_obj.setInteger("is_active", 0);
                otp_obj.update();
                response.setContentType("text/html;charset=UTF-8");
                // Get the printwriter object from response to write the required json object to the output stream      
                PrintWriter out = response.getWriter();
                // Assuming your json object is **jsonObject**, perform the following, it will return your json object  
                Bundle[] bundles = item.getBundles("ORIGINAL");
                Bitstream[] bitstreams = bundles[0].getBitstreams();
                String url =ConfigurationManager.getProperty("dspace.baseUrl") + request.getContextPath()+ "/bitstream/"
                                                            + item.getHandle()
                                                            + "/" + bitstreams[0].getSequenceID()
                                                            + "/" + UIUtil.encodeBitstreamName(bitstreams[0].getName(), Constants.DEFAULT_ENCODING);
                out.print(url);
                out.flush();
                context.complete();
            }
        }
    }

    @Override
    protected void doDSPost(Context context, HttpServletRequest request,
            HttpServletResponse response) throws ServletException, IOException,
            SQLException, AuthorizeException {
    }
}
