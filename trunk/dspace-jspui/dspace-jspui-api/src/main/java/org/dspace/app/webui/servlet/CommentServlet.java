/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.app.webui.servlet;

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

public class CommentServlet extends DSpaceServlet
{
    /** Logger */
    private static Logger log = Logger.getLogger(CommentServlet.class);

    protected void doDSGet(Context context, HttpServletRequest request,
            HttpServletResponse response) throws ServletException, IOException,
            SQLException, AuthorizeException
    {
        // GET just displays the list of communities and collections
        showControls(context, request, response);
    }

    protected void doDSPost(Context context, HttpServletRequest request,
            HttpServletResponse response) throws ServletException, IOException,
            SQLException, AuthorizeException
    {
        
        int item_id = UIUtil.getIntParameter(request, "item_id");
        String handle = request.getParameter("handle");
        String content = request.getParameter("content");
        if(item_id == -1 || content == null){
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
        response.sendRedirect(response.encodeRedirectURL(request
                    .getContextPath()
                    + "/handle/"+ handle));
        
    }

    /**
     * Store in the request attribute to teach to the jsp which button are
     * needed/allowed for the community edit form
     * 
     * @param context
     * @param request
     * @param community
     * @throws SQLException
     */
    private void storeAuthorizeAttributeCommunityEdit(Context context,
            HttpServletRequest request, Community community) throws SQLException
    {
        try 
        {
            AuthorizeUtil.authorizeManageAdminGroup(context, community);                
            request.setAttribute("admin_create_button", Boolean.TRUE);
        }
        catch (AuthorizeException authex) {
            request.setAttribute("admin_create_button", Boolean.FALSE);
        }
        
        try 
        {
            AuthorizeUtil.authorizeRemoveAdminGroup(context, community);                
            request.setAttribute("admin_remove_button", Boolean.TRUE);
        }
        catch (AuthorizeException authex) {
            request.setAttribute("admin_remove_button", Boolean.FALSE);
        }
        
        if (AuthorizeManager.authorizeActionBoolean(context, community, Constants.DELETE))
        {
            request.setAttribute("delete_button", Boolean.TRUE);
        }
        else
        {
            request.setAttribute("delete_button", Boolean.FALSE);
        }
        
        try 
        {
            AuthorizeUtil.authorizeManageCommunityPolicy(context, community);                
            request.setAttribute("policy_button", Boolean.TRUE);
        }
        catch (AuthorizeException authex) {
            request.setAttribute("policy_button", Boolean.FALSE);
        }        
    }
    
    /**
     * Store in the request attribute to teach to the jsp which button are
     * needed/allowed for the collection edit form
     * 
     * @param context
     * @param request
     * @param community
     * @throws SQLException
     */
    static void storeAuthorizeAttributeCollectionEdit(Context context,
            HttpServletRequest request, Collection collection) throws SQLException
    {
        if (AuthorizeManager.isAdmin(context, collection))
        {
            request.setAttribute("admin_collection", Boolean.TRUE);
        }
        else
        {
            request.setAttribute("admin_collection", Boolean.FALSE);
        }
        
        try 
        {
            AuthorizeUtil.authorizeManageAdminGroup(context, collection);                
            request.setAttribute("admin_create_button", Boolean.TRUE);
        }
        catch (AuthorizeException authex) {
            request.setAttribute("admin_create_button", Boolean.FALSE);
        }
        
        try 
        {
            AuthorizeUtil.authorizeRemoveAdminGroup(context, collection);                
            request.setAttribute("admin_remove_button", Boolean.TRUE);
        }
        catch (AuthorizeException authex) {
            request.setAttribute("admin_remove_button", Boolean.FALSE);
        }
        
        try 
        {
            AuthorizeUtil.authorizeManageSubmittersGroup(context, collection);                
            request.setAttribute("submitters_button", Boolean.TRUE);
        }
        catch (AuthorizeException authex) {
            request.setAttribute("submitters_button", Boolean.FALSE);
        }
        
        try 
        {
            AuthorizeUtil.authorizeManageWorkflowsGroup(context, collection);                
            request.setAttribute("workflows_button", Boolean.TRUE);
        }
        catch (AuthorizeException authex) {
            request.setAttribute("workflows_button", Boolean.FALSE);
        }
        
        try 
        {
            AuthorizeUtil.authorizeManageTemplateItem(context, collection);                
            request.setAttribute("template_button", Boolean.TRUE);
        }
        catch (AuthorizeException authex) {
            request.setAttribute("template_button", Boolean.FALSE);
        }
        
        if (AuthorizeManager.authorizeActionBoolean(context, collection.getParentObject(), Constants.REMOVE))
        {
            request.setAttribute("delete_button", Boolean.TRUE);
        }
        else
        {
            request.setAttribute("delete_button", Boolean.FALSE);
        }
        
        try 
        {
            AuthorizeUtil.authorizeManageCollectionPolicy(context, collection);                
            request.setAttribute("policy_button", Boolean.TRUE);
        }
        catch (AuthorizeException authex) {
            request.setAttribute("policy_button", Boolean.FALSE);
        }        
    }

    /**
     * Show community home page with admin controls
     * 
     * @param context
     *            Current DSpace context
     * @param request
     *            Current HTTP request
     * @param response
     *            Current HTTP response
     */
    private void showControls(Context context, HttpServletRequest request,
            HttpServletResponse response) throws ServletException, IOException,
            SQLException, AuthorizeException
    {
        // new approach - eliminate the 'list-communities' page in favor of the
        // community home page, enhanced with admin controls. If no community,
        // or no parent community, just fall back to the community-list page
        Community community = (Community) request.getAttribute("community");
        Collection collection = (Collection) request.getAttribute("collection");
        
        if (collection != null)
        {
            response.sendRedirect(response.encodeRedirectURL(request
                    .getContextPath()
                    + "/handle/" + collection.getHandle()));
        }
        else if (community != null)
        {
            response.sendRedirect(response.encodeRedirectURL(request
                    .getContextPath()
                    + "/handle/" + community.getHandle()));
        }
        else
        {
            // see if a parent community was specified
            Community parent = (Community) request.getAttribute("parent");

            if (parent != null)
            {
                response.sendRedirect(response.encodeRedirectURL(request
                        .getContextPath()
                        + "/handle/" + parent.getHandle()));
            }
            else
            {
                // fall back on community-list page
                response.sendRedirect(response.encodeRedirectURL(request
                        .getContextPath()
                        + "/community-list"));
            }
        }
    }


    /**
     * Create/update collection metadata from a posted form
     * 
     * @param context
     *            DSpace context
     * @param request
     *            the HTTP request containing posted info
     * @param response
     *            the HTTP response
     * @param community
     *            the community the collection is in
     * @param collection
     *            the collection to update (or null for creation)
     */
    private void processConfirmEditCollection(Context context,
            HttpServletRequest request, HttpServletResponse response,
            Community community, Collection collection)
            throws ServletException, IOException, SQLException,
            AuthorizeException
    {
        if (request.getParameter("create").equals("true"))
        {
            // We need to create a new community
            collection = community.createCollection();
            request.setAttribute("collection", collection);
        }
        
        storeAuthorizeAttributeCollectionEdit(context, request, collection);

        // Update the basic metadata
        collection.setMetadata("name", request.getParameter("name"));
        collection.setMetadata("short_description", request
                .getParameter("short_description"));

        String intro = request.getParameter("introductory_text");

        if (intro.equals(""))
        {
            intro = null;
        }

        String copy = request.getParameter("copyright_text");

        if (copy.equals(""))
        {
            copy = null;
        }

        String side = request.getParameter("side_bar_text");

        if (side.equals(""))
        {
            side = null;
        }

        String license = request.getParameter("license");

        if (license.equals(""))
        {
            license = null;
        }

        String provenance = request.getParameter("provenance_description");

        if (provenance.equals(""))
        {
            provenance = null;
        }

        collection.setMetadata("introductory_text", intro);
        collection.setMetadata("copyright_text", copy);
        collection.setMetadata("side_bar_text", side);
        collection.setMetadata("license", license);
        collection.setMetadata("provenance_description", provenance);
        
        
        
        
        // Set the harvesting settings
        
        HarvestedCollection hc = HarvestedCollection.find(context, collection.getID());
		String contentSource = request.getParameter("source");

		// First, if this is not a harvested collection (anymore), set the harvest type to 0; wipe harvest settings  
		if (contentSource.equals("source_normal")) 
		{
			if (hc != null)
            {
                hc.delete();
            }
		}
		else 
		{
			// create a new harvest instance if all the settings check out
			if (hc == null) {
				hc = HarvestedCollection.create(context, collection.getID());
			}
			
			String oaiProvider = request.getParameter("oai_provider");
			String oaiSetId = request.getParameter("oai_setid");
			String metadataKey = request.getParameter("metadata_format");
			String harvestType = request.getParameter("harvest_level");

			hc.setHarvestParams(Integer.parseInt(harvestType), oaiProvider, oaiSetId, metadataKey);
			hc.setHarvestStatus(HarvestedCollection.STATUS_READY);
			
			hc.update();
		}
        
        

        // Which button was pressed?
        String button = UIUtil.getSubmitButton(request, "submit");

        if (button.equals("submit_set_logo"))
        {
            // Change the logo - delete any that might be there first
            collection.setLogo(null);

            // Display "upload logo" page. Necessary attributes already set by
            // doDSPost()
            JSPManager.showJSP(request, response,
                    "/dspace-admin/upload-logo.jsp");
        }
        else if (button.equals("submit_delete_logo"))
        {
            // Simply delete logo
            collection.setLogo(null);

            // Show edit page again - attributes set in doDSPost()
            JSPManager.showJSP(request, response, "/tools/edit-collection.jsp");
        }
        else if (button.startsWith("submit_wf_create_"))
        {
            int step = Integer.parseInt(button.substring(17));

            // Create new group
            Group newGroup = collection.createWorkflowGroup(step);
            collection.update();

            // Forward to group edit page
            response.sendRedirect(response.encodeRedirectURL(request
                    .getContextPath()
                    + "/tools/group-edit?group_id=" + newGroup.getID()));
        }
        else if (button.equals("submit_admins_create"))
        {
            // Create new group
            Group newGroup = collection.createAdministrators();
            collection.update();
            
            // Forward to group edit page
            response.sendRedirect(response.encodeRedirectURL(request
                    .getContextPath()
                    + "/tools/group-edit?group_id=" + newGroup.getID()));
        }
        else if (button.equals("submit_admins_delete"))
        {
        	// Remove the administrators group.
        	Group g = collection.getAdministrators();
        	collection.removeAdministrators();
            collection.update();
            g.delete();

            // Show edit page again - attributes set in doDSPost()
            JSPManager.showJSP(request, response, "/tools/edit-collection.jsp");
        }
        else if (button.equals("submit_submitters_create"))
        {
            // Create new group
            Group newGroup = collection.createSubmitters();
            collection.update();
            
            // Forward to group edit page
            response.sendRedirect(response.encodeRedirectURL(request
                    .getContextPath()
                    + "/tools/group-edit?group_id=" + newGroup.getID()));
        }
        else if (button.equals("submit_submitters_delete"))
        {
        	// Remove the administrators group.
        	Group g = collection.getSubmitters();
        	collection.removeSubmitters();
            collection.update();
            g.delete();

            // Show edit page again - attributes set in doDSPost()
            JSPManager.showJSP(request, response, "/tools/edit-collection.jsp");
        }
        else if (button.equals("submit_authorization_edit"))
        {
            // Forward to policy edit page
            response.sendRedirect(response.encodeRedirectURL(request
                    .getContextPath()
                    + "/tools/authorize?collection_id="
                    + collection.getID() + "&submit_collection_select=1"));
        }
        else if (button.startsWith("submit_wf_edit_"))
        {
            int step = Integer.parseInt(button.substring(15));

            // Edit workflow group
            Group g = collection.getWorkflowGroup(step);
            response.sendRedirect(response.encodeRedirectURL(request
                    .getContextPath()
                    + "/tools/group-edit?group_id=" + g.getID()));
        }
        else if (button.equals("submit_submitters_edit"))
        {
            // Edit submitters group
            Group g = collection.getSubmitters();
            response.sendRedirect(response.encodeRedirectURL(request
                    .getContextPath()
                    + "/tools/group-edit?group_id=" + g.getID()));
        }
        else if (button.equals("submit_admins_edit"))
        {
            // Edit 'collection administrators' group
            Group g = collection.getAdministrators();
            response.sendRedirect(response.encodeRedirectURL(request
                    .getContextPath()
                    + "/tools/group-edit?group_id=" + g.getID()));
        }
        else if (button.startsWith("submit_wf_delete_"))
        {
            // Delete workflow group
            int step = Integer.parseInt(button.substring(17));

            Group g = collection.getWorkflowGroup(step);
            collection.setWorkflowGroup(step, null);

            // Have to update to avoid ref. integrity error
            collection.update();
            g.delete();

            // Show edit page again - attributes set in doDSPost()
            JSPManager.showJSP(request, response, "/tools/edit-collection.jsp");
        }
        else if (button.equals("submit_create_template"))
        {
            // Create a template item
            collection.createTemplateItem();

            // Forward to edit page for new template item
            Item i = collection.getTemplateItem();            

            // save the changes
            collection.update();
            context.complete();
            response.sendRedirect(response.encodeRedirectURL(request
                    .getContextPath()
                    + "/tools/edit-item?item_id=" + i.getID()));

            return;
        }
        else if (button.equals("submit_edit_template"))
        {
            // Forward to edit page for template item
            Item i = collection.getTemplateItem();
            response.sendRedirect(response.encodeRedirectURL(request
                    .getContextPath()
                    + "/tools/edit-item?item_id=" + i.getID()));
        }
        else if (button.equals("submit_delete_template"))
        {
            collection.removeTemplateItem();

            // Show edit page again - attributes set in doDSPost()
            JSPManager.showJSP(request, response, "/tools/edit-collection.jsp");
        }
        else
        {
            // Plain old "create/update" button pressed - go back to main page
            showControls(context, request, response);
        }

        // Commit changes to DB
        collection.update();
        context.complete();
    }

    /**
     * Process the input from the upload logo page
     * 
     * @param context
     *            current DSpace context
     * @param request
     *            current servlet request object
     * @param response
     *            current servlet response object
     */
    private void processUploadLogo(Context context, HttpServletRequest request,
            HttpServletResponse response) throws ServletException, IOException,
            SQLException, AuthorizeException
    {
        try {
            // Wrap multipart request to get the submission info
            FileUploadRequest wrapper = new FileUploadRequest(request);
            Community community = Community.find(context, UIUtil.getIntParameter(wrapper, "community_id"));
            Collection collection = Collection.find(context, UIUtil.getIntParameter(wrapper, "collection_id"));
            File temp = wrapper.getFile("file");

            // Read the temp file as logo
            InputStream is = new BufferedInputStream(new FileInputStream(temp));
            Bitstream logoBS;

            if (collection == null)
            {
                logoBS = community.setLogo(is);
            }
            else
            {
                logoBS = collection.setLogo(is);
            }

            // Strip all but the last filename. It would be nice
            // to know which OS the file came from.
            String noPath = wrapper.getFilesystemName("file");

            while (noPath.indexOf('/') > -1)
            {
                noPath = noPath.substring(noPath.indexOf('/') + 1);
            }

            while (noPath.indexOf('\\') > -1)
            {
                noPath = noPath.substring(noPath.indexOf('\\') + 1);
            }

            logoBS.setName(noPath);
            logoBS.setSource(wrapper.getFilesystemName("file"));

            // Identify the format
            BitstreamFormat bf = FormatIdentifier.guessFormat(context, logoBS);
            logoBS.setFormat(bf);
            AuthorizeManager.addPolicy(context, logoBS, Constants.WRITE, context.getCurrentUser());
            logoBS.update();

            String jsp;
            DSpaceObject dso;
            if (collection == null)
            {
                community.update();

                // Show community edit page
                request.setAttribute("community", community);
                storeAuthorizeAttributeCommunityEdit(context, request, community);
                dso = community;
                jsp = "/tools/edit-community.jsp";
            } 
            else
            {
                collection.update();

                // Show collection edit page
                request.setAttribute("collection", collection);
                request.setAttribute("community", community);
                storeAuthorizeAttributeCollectionEdit(context, request, collection);
                dso = collection;
                jsp = "/tools/edit-collection.jsp";
            }
            
            if (AuthorizeManager.isAdmin(context, dso))
            {
                // set a variable to show all buttons
                request.setAttribute("admin_button", Boolean.TRUE);
            }

            JSPManager.showJSP(request, response, jsp);

            // Remove temp file
            if (!temp.delete())
            {
                log.error("Unable to delete temporary file");
            }

            // Update DB
            context.complete();
        } catch (FileSizeLimitExceededException ex)
        {
            log.warn("Upload exceeded upload.max");
            JSPManager.showFileSizeLimitExceededError(request, response, ex.getMessage(), ex.getActualSize(), ex.getPermittedSize());
        }
    }
}
