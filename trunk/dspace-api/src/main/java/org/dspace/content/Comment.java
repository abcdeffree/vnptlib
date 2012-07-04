/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.content;

import java.io.IOException;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.MissingResourceException;

import org.apache.commons.lang.builder.HashCodeBuilder;
import org.apache.log4j.Logger;
import org.dspace.authorize.AuthorizeException;
import org.dspace.authorize.AuthorizeManager;
import org.dspace.authorize.ResourcePolicy;
import org.dspace.core.Constants;
import org.dspace.core.Context;
import org.dspace.core.I18nUtil;
import org.dspace.core.LogManager;
import org.dspace.eperson.EPerson;
import org.dspace.eperson.Group;
import org.dspace.event.Event;
import org.dspace.handle.HandleManager;
import org.dspace.storage.rdbms.DatabaseManager;
import org.dspace.storage.rdbms.TableRow;
import org.dspace.storage.rdbms.TableRowIterator;

/**
 * Class representing a community
 * <P>
 * The community's metadata (name, introductory text etc.) is loaded into'
 * memory. Changes to this metadata are only reflected in the database after
 * <code>update</code> is called.
 * 
 * @author Robert Tansley
 * @version $Revision: 5844 $
 */
public class Comment extends DSpaceObject
{
    /** log4j category */
    private static Logger log = Logger.getLogger(Comment.class);

    /** Our context */
    private Context ourContext;

    /** The table row corresponding to this item */
    private TableRow commentRow;


    /** Handle, if any */
    private String handle;
    /** Flag set when data is modified, for events */
    private boolean modified;

    /** Flag set when metadata is modified, for events */
    private boolean modifiedMetadata;

    /**
     * Construct a comment object from a database row.
     * 
     * @param context
     *            the context this object exists in
     * @param row
     *            the corresponding row in the table
     */
    Comment(Context context, TableRow row) throws SQLException
    {
        ourContext = context;
        commentRow = row;


        // Get our Handle if any
        handle = HandleManager.findHandle(context, this);

        // Cache ourselves
        context.cache(this, row.getIntColumn("comment_id"));

        clearDetails();
    }

    /**
     * Get a community from the database. Loads in the metadata
     * 
     * @param context
     *            DSpace context object
     * @param id
     *            ID of the community
     * 
     * @return the community, or null if the ID is invalid.
     */
    public static Comment find(Context context, int id) throws SQLException
    {
        // First check the cache
        Comment fromCache = (Comment) context
                .fromCache(Comment.class, id);

        if (fromCache != null)
        {
            return fromCache;
        }

        TableRow row = DatabaseManager.find(context, "comment", id);

        if (row == null)
        {
            if (log.isDebugEnabled())
            {
                log.debug(LogManager.getHeader(context, "find_comment",
                        "not_found,comment_id=" + id));
            }

            return null;
        }
        else
        {
            if (log.isDebugEnabled())
            {
                log.debug(LogManager.getHeader(context, "find_community",
                        "community_id=" + id));
            }

            return new Comment(context, row);
        }
    }

    /**
     * Create a new top-level community, with a new ID.
     * 
     * @param context
     *            DSpace context object
     * 
     * @return the newly created community
     */
    public static Comment create(Context context)
            throws SQLException, AuthorizeException
    {
        return create(context, null);
    }

    /**
     * Create a new top-level community, with a new ID.
     *
     * @param context
     *            DSpace context object
     * @param handle the pre-determined Handle to assign to the new community
     *
     * @return the newly created community
     */
    public static Comment create(Context context, String handle)
            throws SQLException, AuthorizeException
    {
        TableRow row = DatabaseManager.create(context, "comment");
        Comment c = new Comment(context, row);
        
        try
        {
            c.handle = (handle == null) ?
                       HandleManager.createHandle(context, c) :
                       HandleManager.createHandle(context, c, handle);
        }
        catch(IllegalStateException ie)
        {
            //If an IllegalStateException is thrown, then an existing object is already using this handle
            //Remove the community we just created -- as it is incomplete
            try
            {
                if(c!=null)
                {
                    c.delete();
                }
            } catch(Exception e) { }

            //pass exception on up the chain
            throw ie;
        }

        return c;
    }

    /**
     * Get a list of all communities in the system. These are alphabetically
     * sorted by community name.
     * 
     * @param context
     *            DSpace context object
     * 
     * @return the communities in the system
     */
    public static Comment[] findAll(Context context) throws SQLException
    {
        TableRowIterator tri = DatabaseManager.queryTable(context, "community",
                "SELECT * FROM community ORDER BY name");

        List<Comment> communities = new ArrayList<Comment>();

        try
        {
            while (tri.hasNext())
            {
                TableRow row = tri.next();

                // First check the cache
                Comment fromCache = (Comment) context.fromCache(
                        Comment.class, row.getIntColumn("community_id"));

                if (fromCache != null)
                {
                    communities.add(fromCache);
                }
                else
                {
                    communities.add(new Comment(context, row));
                }
            }
        }
        finally
        {
            // close the TableRowIterator to free up resources
            if (tri != null)
            {
                tri.close();
            }
        }

        Comment[] communityArray = new Comment[communities.size()];
        communityArray = (Comment[]) communities.toArray(communityArray);

        return communityArray;
    }

    /**
     * Get a list of all top-level communities in the system. These are
     * alphabetically sorted by community name. A top-level community is one
     * without a parent community.
     * 
     * @param context
     *            DSpace context object
     * 
     * @return the top-level communities in the system
     */
    public static Comment[] findAllTop(Context context) throws SQLException
    {
        // get all communities that are not children
        TableRowIterator tri = DatabaseManager.queryTable(context, "community",
                "SELECT * FROM community WHERE NOT community_id IN "
                        + "(SELECT child_comm_id FROM community2community) "
                        + "ORDER BY name");

        List<Comment> topCommunities = new ArrayList<Comment>();

        try
        {
            while (tri.hasNext())
            {
                TableRow row = tri.next();

                // First check the cache
                Comment fromCache = (Comment) context.fromCache(
                        Comment.class, row.getIntColumn("community_id"));

                if (fromCache != null)
                {
                    topCommunities.add(fromCache);
                }
                else
                {
                    topCommunities.add(new Comment(context, row));
                }
            }
        }
        finally
        {
            // close the TableRowIterator to free up resources
            if (tri != null)
            {
                tri.close();
            }
        }

        Comment[] communityArray = new Comment[topCommunities.size()];
        communityArray = (Comment[]) topCommunities.toArray(communityArray);

        return communityArray;
    }

    /**
     * Get the internal ID of this collection
     * 
     * @return the internal identifier
     */
    public int getID()
    {
        return commentRow.getIntColumn("comment_id");
    }

    /**
     * @see org.dspace.content.DSpaceObject#getHandle()
     */
    public String getHandle()
    {
        if(handle == null) {
        	try {
				handle = HandleManager.findHandle(this.ourContext, this);
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				//e.printStackTrace();
			}
        }
    	return handle;
    }


    /**
     * Update the community metadata (including logo) to the database.
     */
    public void update() throws SQLException, IOException, AuthorizeException
    {
        // Check authorisation

        log.info(LogManager.getHeader(ourContext, "update_comment",
                "comment_id=" + getID()));

        DatabaseManager.update(ourContext, commentRow);

        
    }

    /**
     * Delete the community, including the metadata and logo. Collections and
     * subcommunities that are then orphans are deleted.
     */
    public void delete() throws SQLException, AuthorizeException, IOException
    {
        // Check authorisation
        // FIXME: If this was a subcommunity, it is first removed from it's
        // parent.
        // This means the parentCommunity == null
        // But since this is also the case for top-level communities, we would
        // give everyone rights to remove the top-level communities.
        // The same problem occurs in removing the logo

        // If not a top-level community, have parent remove me; this
        // will call rawDelete() before removing the linkage
//        Comment parent = getParentCommunity();
//
//        if (parent != null)
//        {
//            // remove the subcommunities first
//            Comment[] subcommunities = getSubcommunities();
//            for (int i = 0; i < subcommunities.length; i++)
//            {
//                subcommunities[i].delete();
//            }
//            // now let the parent remove the community
//            parent.removeSubcommunity(this);
//
//            return;
//        }

    }
    

    /**
     * Return <code>true</code> if <code>other</code> is the same Community
     * as this object, <code>false</code> otherwise
     * 
     * @param other
     *            object to compare to
     * 
     * @return <code>true</code> if object passed in represents the same
     *         community as this object
     */
    public boolean equals(Object other)
    {
        if (!(other instanceof Comment))
        {
            return false;
        }

        return (getID() == ((Comment) other).getID());
    }

    public int hashCode()
    {
        return new HashCodeBuilder().append(getID()).toHashCode();
    }

    /**
     * Utility method for reading in a group from a group ID in a column. If the
     * column is null, null is returned.
     * 
     * @param col
     *            the column name to read
     * @return the group referred to by that column, or null
     * @throws SQLException
     */
    private Group groupFromColumn(String col) throws SQLException
    {
        if (commentRow.isColumnNull(col))
        {
            return null;
        }

        return Group.find(ourContext, commentRow.getIntColumn(col));
    }
    /**
     * return type found in Constants
     */
    public int getType()
    {
        return Constants.COMMUNITY;
    }

 
    
    public DSpaceObject getParentObject() throws SQLException
    {
        throw new UnsupportedOperationException("Not supported yet.");
//        Comment pCommunity = getParentCommunity();
//        if (pCommunity != null)
//        {
//            return pCommunity;
//        }
//        else
//        {
//            return null;
//        }       
    }

    @Override
    public String getName() {
        throw new UnsupportedOperationException("Not supported yet.");
    }
    /**
     * Get the value of a metadata field
     * 
     * @param field
     *            the name of the metadata field to get
     * 
     * @return the value of the metadata field
     * 
     * @exception IllegalArgumentException
     *                if the requested metadata field doesn't exist
     */
    public String getMetadata(String field)
    {
    	String metadata = commentRow.getStringColumn(field);
    	return (metadata == null) ? "" : metadata;
    }

    /**
     * Set a metadata value
     * 
     * @param field
     *            the name of the metadata field to get
     * @param value
     *            value to set the field to
     * 
     * @exception IllegalArgumentException
     *                if the requested metadata field doesn't exist
     * @exception MissingResourceException
     */
    public void setMetadata(String field, String value)throws MissingResourceException
    {
        /* 
         * Set metadata field to null if null 
         * and trim strings to eliminate excess
         * whitespace.
         */
        if(value == null)
        {
            commentRow.setColumnNull(field);
        }
        else
        {
            commentRow.setColumn(field, value.trim());
        }
        
        modifiedMetadata = true;
        addDetails(field);
    }
    public void setInteger(String field, int value)throws MissingResourceException
    {
        /* 
         * Set metadata field to null if null 
         * and trim strings to eliminate excess
         * whitespace.
         */

        commentRow.setColumn(field, value);
        modifiedMetadata = true;
        addDetails(field);
    }
    public void setTimestamp(String field, Date value)throws MissingResourceException
    {
        /* 
         * Set metadata field to null if null 
         * and trim strings to eliminate excess
         * whitespace.
         */

        commentRow.setColumn(field, value);
        modifiedMetadata = true;
        addDetails(field);
    }
    /**
     * Get the value of a metadata field
     * 
     * @param field
     *            the name of the metadata field to get
     * 
     * @return the value of the metadata field
     * 
     * @exception IllegalArgumentException
     *                if the requested metadata field doesn't exist
     */
    public String getDate()
    {
    	Date date = commentRow.getDateColumn("created_at");
        SimpleDateFormat dateformat = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss");
        String metadata = dateformat.format(date);
    	return metadata;
    }
    public String getMemberName() throws SQLException{
        int user_id = commentRow.getIntColumn("user_id");
        EPerson person = EPerson.find(ourContext, user_id);
        return person.getFullName();
    }
}
