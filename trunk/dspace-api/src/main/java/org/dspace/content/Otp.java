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
import org.dspace.event.Event;
import org.dspace.handle.HandleManager;
import org.dspace.storage.rdbms.DatabaseManager;
import org.dspace.storage.rdbms.TableRow;
import org.dspace.storage.rdbms.TableRowIterator;

/**
 * Class representing a otp
 * <P>
 * The otp's metadata (name, introductory text etc.) is loaded into'
 * memory. Changes to this metadata are only reflected in the database after
 * <code>update</code> is called.
 * 
 * @author Robert Tansley
 * @version $Revision: 5844 $
 */
public class Otp extends DSpaceObject
{
    /** log4j category */
    private static Logger log = Logger.getLogger(Otp.class);

    /** Our context */
    private Context ourContext;

    /** The table row corresponding to this item */
    private TableRow otpRow;


    /** Handle, if any */
    private String handle;
    /** Flag set when data is modified, for events */
    private boolean modified;

    /** Flag set when metadata is modified, for events */
    private boolean modifiedMetadata;

    /**
     * Construct a otp object from a database row.
     * 
     * @param context
     *            the context this object exists in
     * @param row
     *            the corresponding row in the table
     */
    Otp(Context context, TableRow row) throws SQLException
    {
        ourContext = context;
        otpRow = row;


        // Get our Handle if any
        handle = HandleManager.findHandle(context, this);

        // Cache ourselves
        context.cache(this, row.getIntColumn("otp_id"));

        clearDetails();
    }

    /**
     * Get a otp from the database. Loads in the metadata
     * 
     * @param context
     *            DSpace context object
     * @param id
     *            ID of the otp
     * 
     * @return the otp, or null if the ID is invalid.
     */
    public static Otp find(Context context, int id) throws SQLException
    {
        // First check the cache
        Otp fromCache = (Otp) context
                .fromCache(Otp.class, id);

        if (fromCache != null)
        {
            return fromCache;
        }

        TableRow row = DatabaseManager.find(context, "otp", id);

        if (row == null)
        {
            if (log.isDebugEnabled())
            {
                log.debug(LogManager.getHeader(context, "find_otp",
                        "not_found,otp_id=" + id));
            }

            return null;
        }
        else
        {
            if (log.isDebugEnabled())
            {
                log.debug(LogManager.getHeader(context, "find_otp",
                        "otp_id=" + id));
            }

            return new Otp(context, row);
        }
    }

    /**
     * Create a new top-level otp, with a new ID.
     * 
     * @param context
     *            DSpace context object
     * 
     * @return the newly created otp
     */
    public static Otp create(Context context)
            throws SQLException, AuthorizeException
    {
        return create(context, null);
    }

    /**
     * Create a new top-level otp, with a new ID.
     *
     * @param context
     *            DSpace context object
     * @param handle the pre-determined Handle to assign to the new otp
     *
     * @return the newly created otp
     */
    public static Otp create(Context context, String handle)
            throws SQLException, AuthorizeException
    {
        TableRow row = DatabaseManager.create(context, "otp");
        Otp c = new Otp(context, row);
        
        try
        {
            c.handle = (handle == null) ?
                       HandleManager.createHandle(context, c) :
                       HandleManager.createHandle(context, c, handle);
        }
        catch(IllegalStateException ie)
        {
            //If an IllegalStateException is thrown, then an existing object is already using this handle
            //Remove the otp we just created -- as it is incomplete
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
     * Find the otp by their email address.
     * 
     * @return EPerson, or {@code null} if none such exists.
     */
    public static Otp findByOtp(Context context, String otp)
            throws SQLException, AuthorizeException
    {
        if (otp == null)
        {
            return null;
        }
        
        // All email addresses are stored as lowercase, so ensure that the email address is lowercased for the lookup 
        TableRow row = DatabaseManager.findByUnique(context, "otp",
                "otp", otp.toLowerCase());

        if (row == null)
        {
            return null;
        }
        else
        {
            // First check the cache
            Otp fromCache = (Otp) context.fromCache(Otp.class, row
                    .getIntColumn("otp_id"));

            if (fromCache != null)
            {
                return fromCache;
            }
            else
            {
                return new Otp(context, row);
            }
        }
    }

    /**
     * Get a list of all top-level communities in the system. These are
     * alphabetically sorted by otp name. A top-level otp is one
     * without a parent otp.
     * 
     * @param context
     *            DSpace context object
     * 
     * @return the top-level communities in the system
     */
    public static Otp[] findAllTop(Context context) throws SQLException
    {
        // get all communities that are not children
        TableRowIterator tri = DatabaseManager.queryTable(context, "otp",
                "SELECT * FROM otp WHERE otp = ");

        List<Otp> topCommunities = new ArrayList<Otp>();

        try
        {
            while (tri.hasNext())
            {
                TableRow row = tri.next();

                // First check the cache
                Otp fromCache = (Otp) context.fromCache(
                        Otp.class, row.getIntColumn("otp_id"));

                if (fromCache != null)
                {
                    topCommunities.add(fromCache);
                }
                else
                {
                    topCommunities.add(new Otp(context, row));
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

        Otp[] otpArray = new Otp[topCommunities.size()];
        otpArray = (Otp[]) topCommunities.toArray(otpArray);

        return otpArray;
    }

    /**
     * Get the internal ID of this collection
     * 
     * @return the internal identifier
     */
    public int getID()
    {
        return otpRow.getIntColumn("otp_id");
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
     * Update the otp metadata (including logo) to the database.
     */
    public void update() throws SQLException, IOException, AuthorizeException
    {
        // Check authorisation

        log.info(LogManager.getHeader(ourContext, "update_otp",
                "otp_id=" + getID()));

        DatabaseManager.update(ourContext, otpRow);

        
    }

    /**
     * Delete the otp, including the metadata and logo. Collections and
     * subcommunities that are then orphans are deleted.
     */
    public void delete() throws SQLException, AuthorizeException, IOException
    {
        // Check authorisation
        // FIXME: If this was a subotp, it is first removed from it's
        // parent.
        // This means the parentOtp == null
        // But since this is also the case for top-level communities, we would
        // give everyone rights to remove the top-level communities.
        // The same problem occurs in removing the logo

        // If not a top-level otp, have parent remove me; this
        // will call rawDelete() before removing the linkage
//        Otp parent = getParentOtp();
//
//        if (parent != null)
//        {
//            // remove the subcommunities first
//            Otp[] subcommunities = getSubcommunities();
//            for (int i = 0; i < subcommunities.length; i++)
//            {
//                subcommunities[i].delete();
//            }
//            // now let the parent remove the otp
//            parent.removeSubotp(this);
//
//            return;
//        }

    }
    

    /**
     * Return <code>true</code> if <code>other</code> is the same Otp
     * as this object, <code>false</code> otherwise
     * 
     * @param other
     *            object to compare to
     * 
     * @return <code>true</code> if object passed in represents the same
     *         otp as this object
     */
    public boolean equals(Object other)
    {
        if (!(other instanceof Otp))
        {
            return false;
        }

        return (getID() == ((Otp) other).getID());
    }

    public int hashCode()
    {
        return new HashCodeBuilder().append(getID()).toHashCode();
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
    	String metadata = otpRow.getStringColumn(field);
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
            otpRow.setColumnNull(field);
        }
        else
        {
            otpRow.setColumn(field, value.trim());
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

        otpRow.setColumn(field, value);
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

        otpRow.setColumn(field, value);
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
    	Date date = otpRow.getDateColumn("created_at");
        SimpleDateFormat dateformat = new SimpleDateFormat("dd-MM-yyyy HH:mm:ss");
        String metadata = dateformat.format(date);
    	return metadata;
    }

    @Override
    public int getType() {
        throw new UnsupportedOperationException("Not supported yet.");
    }
}
