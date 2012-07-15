/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package org.dspace.app.webui.servlet;

/**
 *
 * @author ThucLH
 */
import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
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

    protected void doDSGet(Context context, HttpServletRequest request,
            HttpServletResponse response) throws ServletException, IOException,
            SQLException, AuthorizeException {
        int item_id = UIUtil.getIntParameter(request, "item_id");
        String handle = request.getParameter("handle");
        String content = request.getParameter("content");
        if (item_id == -1 || content == null) {
            response.sendRedirect(request.getContextPath());
        }
        EPerson currentUser = context.getCurrentUser();

        Comment comment = Comment.create(context);
        comment.setMetadata("content", content);
        comment.setInteger("item_id", item_id);
        comment.setInteger("user_id", currentUser.getID());
        comment.setTimestamp("created_at", new Date());
        comment.update();
        context.complete();
        response.sendRedirect(response.encodeRedirectURL(request.getContextPath()
                + "/handle/" + handle));
    }

    protected void doDSPost(Context context, HttpServletRequest request,
            HttpServletResponse response) throws ServletException, IOException,
            SQLException, AuthorizeException {

        int item_id = UIUtil.getIntParameter(request, "item_id");
        String handle = request.getParameter("handle");
        String content = request.getParameter("content");
        if (item_id == -1 || content == null) {
            response.sendRedirect(request.getContextPath());
        }
        EPerson currentUser = context.getCurrentUser();

        Comment comment = Comment.create(context);
        comment.setMetadata("content", content);
        comment.setInteger("item_id", item_id);
        comment.setInteger("user_id", currentUser.getID());
        comment.setTimestamp("created_at", new Date());
        comment.update();
        context.complete();
        response.sendRedirect(response.encodeRedirectURL(request.getContextPath()
                + "/handle/" + handle));

    }
}
