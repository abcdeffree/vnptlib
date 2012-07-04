/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.app.webui.jsptag;

import org.apache.commons.lang.ArrayUtils;
import org.apache.commons.lang.StringUtils;
import org.apache.log4j.Logger;
import org.dspace.app.webui.util.UIUtil;

import org.dspace.browse.BrowseException;
import org.dspace.browse.BrowseIndex;
import org.dspace.browse.CrossLinks;

import org.dspace.content.Bitstream;
import org.dspace.content.DCDate;
import org.dspace.content.DCValue;
import org.dspace.content.Item;
import org.dspace.content.Thumbnail;
import org.dspace.content.service.ItemService;

import org.dspace.core.ConfigurationManager;
import org.dspace.core.Constants;
import org.dspace.core.Context;
import org.dspace.core.Utils;

import org.dspace.sort.SortOption;
import org.dspace.storage.bitstore.BitstreamStorageManager;

import java.awt.image.BufferedImage;

import java.io.IOException;
import java.io.InputStream;
import java.io.UnsupportedEncodingException;

import java.net.URLEncoder;
import java.sql.SQLException;
import java.util.StringTokenizer;

import javax.imageio.ImageIO;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.jsp.JspException;
import javax.servlet.jsp.JspWriter;
import javax.servlet.jsp.jstl.fmt.LocaleSupport;
import javax.servlet.jsp.tagext.TagSupport;
import org.dspace.content.*;
import org.dspace.content.authority.MetadataAuthorityManager;

/**
 * Tag for display a list of items
 *
 * @author Robert Tansley
 * @version $Revision: 5845 $
 */
public class ItemListTag extends TagSupport
{
    private static Logger log = Logger.getLogger(ItemListTag.class);

    /** Items to display */
    private transient Item[] items;

    /** Row to highlight, -1 for no row */
    private int highlightRow = -1;

    /** Column to emphasise - null, "title" or "date" */
    private String emphColumn;

    /** Config value of thumbnail view toggle */
    private static boolean showThumbs;

    /** Config browse/search width and height */
    private static int thumbItemListMaxWidth;

    private static int thumbItemListMaxHeight;

    /** Config browse/search thumbnail link behaviour */
    private static boolean linkToBitstream = false;

    /** Config to include an edit link */
    private boolean linkToEdit = false;

    /** Config to disable cross links */
    private boolean disableCrossLinks = false;

    /** The default fields to be displayed when listing items */
    private static final String DEFAULT_LIST_FIELDS;

    /** The default widths for the columns */
    private static final String DEFAULT_LIST_WIDTHS;

    /** The default field which is bound to the browse by date */
    private static String dateField = "dc.date.issued";

    /** The default field which is bound to the browse by title */
    private static String titleField = "dc.title";

    private static String authorField = "dc.contributor.*";

    private int authorLimit = -1;

    private transient SortOption sortOption = null;

    private static final long serialVersionUID = 348762897199116432L;

    static
    {
        getThumbSettings();

        if (showThumbs)
        {
            DEFAULT_LIST_FIELDS = "thumbnail, dc.date.issued(date), dc.title, dc.contributor.*";
            DEFAULT_LIST_WIDTHS = "*, 130, 60%, 40%";
        }
        else
        {
            DEFAULT_LIST_FIELDS = "dc.date.issued(date), dc.title, dc.contributor.*";
            DEFAULT_LIST_WIDTHS = "130, 60%, 40%";
        }

        // get the date and title fields
        String dateLine = ConfigurationManager.getProperty("webui.browse.index.date");
        if (dateLine != null)
        {
            dateField = dateLine;
        }

        String titleLine = ConfigurationManager.getProperty("webui.browse.index.title");
        if (titleLine != null)
        {
            titleField = titleLine;
        }

        String authorLine = ConfigurationManager.getProperty("webui.browse.author-field");
        if (authorLine != null)
        {
            authorField = authorLine;
        }
    }

    public ItemListTag()
    {
        super();
    }

    public int doStartTag() throws JspException
    {
        JspWriter out = pageContext.getOut();
        HttpServletRequest hrq = (HttpServletRequest) pageContext.getRequest();

        boolean emphasiseDate = false;
        boolean emphasiseTitle = false;

        if (emphColumn != null)
        {
            emphasiseDate = emphColumn.equalsIgnoreCase("date");
            emphasiseTitle = emphColumn.equalsIgnoreCase("title");
        }

        // get the elements to display
        String configLine = null;
        String widthLine  = null;

        if (sortOption != null)
        {
            if (configLine == null)
            {
                configLine = ConfigurationManager.getProperty("webui.itemlist.sort." + sortOption.getName() + ".columns");
                widthLine  = ConfigurationManager.getProperty("webui.itemlist.sort." + sortOption.getName() + ".widths");
            }

            if (configLine == null)
            {
                configLine = ConfigurationManager.getProperty("webui.itemlist." + sortOption.getName() + ".columns");
                widthLine  = ConfigurationManager.getProperty("webui.itemlist." + sortOption.getName() + ".widths");
            }
        }

        if (configLine == null)
        {
            configLine = ConfigurationManager.getProperty("webui.itemlist.columns");
            widthLine  = ConfigurationManager.getProperty("webui.itemlist.widths");
        }

        // Have we read a field configration from dspace.cfg?
        if (configLine != null)
        {
            // If thumbnails are disabled, strip out any thumbnail column from the configuration
            if (!showThumbs && configLine.contains("thumbnail"))
            {
                // Ensure we haven't got any nulls
                configLine = configLine  == null ? "" : configLine;
                widthLine  = widthLine   == null ? "" : widthLine;

                // Tokenize the field and width lines
                StringTokenizer llt = new StringTokenizer(configLine,  ",");
                StringTokenizer wlt = new StringTokenizer(widthLine, ",");

                StringBuilder newLLine = new StringBuilder();
                StringBuilder newWLine = new StringBuilder();
                while (llt.hasMoreTokens() || wlt.hasMoreTokens())
                {
                    String listTok  = llt.hasMoreTokens() ? llt.nextToken() : null;
                    String widthTok = wlt.hasMoreTokens() ? wlt.nextToken() : null;

                    // Only use the Field and Width tokens, if the field isn't 'thumbnail'
                    if (listTok == null || !listTok.trim().equals("thumbnail"))
                    {
                        if (listTok != null)
                        {
                            if (newLLine.length() > 0)
                            {
                                newLLine.append(",");
                            }

                            newLLine.append(listTok);
                        }

                        if (widthTok != null)
                        {
                            if (newWLine.length() > 0)
                            {
                                newWLine.append(",");
                            }

                            newWLine.append(widthTok);
                        }
                    }
                }

                // Use the newly built configuration file
                configLine  = newLLine.toString();
                widthLine = newWLine.toString();
            }
        }
        else
        {
            configLine = DEFAULT_LIST_FIELDS;
            widthLine = DEFAULT_LIST_WIDTHS;
        }

        // Arrays used to hold the information we will require when outputting each row
        String[] fieldArr  = configLine == null ? new String[0] : configLine.split("\\s*,\\s*");

        try
        {
            // but not if we have to add an 'edit item' button - we can't know how big it will be
            // now output each item row
            for (int i = 0; i < items.length; i++)
            {
                // now prepare the XHTML frag for this division
                String rOddOrEven;
                if (i == highlightRow)
                {
                    rOddOrEven = "highlight";
                }
                else
                {
                    rOddOrEven = ((i & 1) == 1 ? "odd" : "even");
                }
                DCValue[] dcv = items[i].getMetadata("dc", "title", null, Item.ANY);
                String displayTitle = "Không có tiêu đề";
                if (dcv != null) {
                    if (dcv.length > 0) {
                        displayTitle = dcv[0].value;
                    }
                }
                DCValue[] dcdes = items[i].getMetadata("dc", "description", null, Item.ANY);
                String description = "Không có mô tả";
                if (dcdes != null) {
                    if (dcdes.length > 0) {
                        description = dcdes[0].value;
                    }
                }
                DCValue[] dcauthor = items[i].getMetadata("dc", "contributor", "author", Item.ANY);
                String authorval = "";
                if (dcauthor != null) {
                    if (dcauthor.length > 0) {
                        authorval = dcauthor[0].value;
                    }
                }
                DCValue[] dcdaccess = items[i].getMetadata("dc", "date", "accessioned", Item.ANY);
                String dateaccessioned = "";
                if (dcdaccess != null) {
                    if (dcdaccess.length > 0) {
                        dateaccessioned = dcdaccess[0].value;
                        DCDate dateaccesionval = new DCDate(dateaccessioned);
                        dateaccessioned = UIUtil.displayDate(dateaccesionval, true, true, (HttpServletRequest)pageContext.getRequest());
                    }
                }
                DCValue[] dateissued = items[i].getMetadata("dc", "date", "issued", Item.ANY);
                String dateissuedval = "";
                if (dateissued != null) {
                    if (dateissued.length > 0) {
                        dateissuedval = dateissued[0].value;
//                        DCDate dateissuedvaldate = new DCDate(dateissuedval);
//                        dateissuedval = UIUtil.displayDate(dateissuedvaldate, true, true, (HttpServletRequest)pageContext.getRequest());
                    }
                }
                Collection[] collections = items[i].getCollections();
//                DCDate dateaccesionval = new DCDate(items[i].getLastModified());
                out.print("<div class='div_recent_item "+rOddOrEven+"'>");
                out.print("<p class='recentItem'>");
                out.print("<img  class='a_recentitem' src='"+hrq.getContextPath()+"/image/transparent.gif'/>");
                out.print("<a class='a_item_title' href='"+hrq.getContextPath()+"/handle/"+ items[i].getHandle()+"'>"+displayTitle+"</a>");
                out.print("<span class='span_date_right'>"+dateaccessioned+"</span>");
                out.print("</p>");
                out.print("<p class='dc_description'>"+description+"</p>");
                
                out.print("<p class='info_preview'>");
                for (int j = 0; j < collections.length; j++) {
                    out.print("<a href='"+hrq.getContextPath()+"/handle/"+collections[j].getHandle()+"'>"+ collections[j].getMetadata("name") +"</a>");
                }
                if(!"".equals(authorval)){
                    out.print("&nbsp;-&nbsp;Tác giả: <span>"+authorval+"</span>");
                }
                if(!"".equals(dateissuedval)){
                    out.print("&nbsp;-&nbsp;Xuất bản: <span>"+dateissuedval+"</span>");
                }
                out.print("</p>");
                out.print("</div>");

            }

        }catch (IOException ie)
        {
            throw new JspException(ie);
        }
        catch (SQLException e)
        {
        	throw new JspException(e);
        }

        return SKIP_BODY;
    }

    public int getAuthorLimit()
    {
        return authorLimit;
    }

    public void setAuthorLimit(int al)
    {
        authorLimit = al;
    }

    public boolean getLinkToEdit()
    {
        return linkToEdit;
    }

    public void setLinkToEdit(boolean edit)
    {
        this.linkToEdit = edit;
    }

    public boolean getDisableCrossLinks()
    {
        return disableCrossLinks;
    }

    public void setDisableCrossLinks(boolean links)
    {
        this.disableCrossLinks = links;
    }

    public SortOption getSortOption()
    {
        return sortOption;
    }

    public void setSortOption(SortOption so)
    {
        sortOption = so;
    }

    /**
     * Get the items to list
     *
     * @return the items
     */
    public Item[] getItems()
    {
        return (Item[]) ArrayUtils.clone(items);
    }

    /**
     * Set the items to list
     *
     * @param itemsIn
     *            the items
     */
    public void setItems(Item[] itemsIn)
    {
        items = (Item[]) ArrayUtils.clone(itemsIn);
    }

    /**
     * Get the row to highlight - null or -1 for no row
     *
     * @return the row to highlight
     */
    public String getHighlightrow()
    {
        return String.valueOf(highlightRow);
    }

    /**
     * Set the row to highlight
     *
     * @param highlightRowIn
     *            the row to highlight or -1 for no highlight
     */
    public void setHighlightrow(String highlightRowIn)
    {
        if ((highlightRowIn == null) || highlightRowIn.equals(""))
        {
            highlightRow = -1;
        }
        else
        {
            try
            {
                highlightRow = Integer.parseInt(highlightRowIn);
            }
            catch (NumberFormatException nfe)
            {
                highlightRow = -1;
            }
        }
    }

    /**
     * Get the column to emphasise - "title", "date" or null
     *
     * @return the column to emphasise
     */
    public String getEmphcolumn()
    {
        return emphColumn;
    }

    /**
     * Set the column to emphasise - "title", "date" or null
     *
     * @param emphColumnIn
     *            column to emphasise
     */
    public void setEmphcolumn(String emphColumnIn)
    {
        emphColumn = emphColumnIn;
    }

    public void release()
    {
        highlightRow = -1;
        emphColumn = null;
        items = null;
    }

    /* get the required thumbnail config items */
    private static void getThumbSettings()
    {
        showThumbs = ConfigurationManager
                .getBooleanProperty("webui.browse.thumbnail.show");

        if (showThumbs)
        {
            thumbItemListMaxHeight = ConfigurationManager
                    .getIntProperty("webui.browse.thumbnail.maxheight");

            if (thumbItemListMaxHeight == 0)
            {
                thumbItemListMaxHeight = ConfigurationManager
                        .getIntProperty("thumbnail.maxheight");
            }

            thumbItemListMaxWidth = ConfigurationManager
                    .getIntProperty("webui.browse.thumbnail.maxwidth");

            if (thumbItemListMaxWidth == 0)
            {
                thumbItemListMaxWidth = ConfigurationManager
                        .getIntProperty("thumbnail.maxwidth");
            }
        }

        String linkBehaviour = ConfigurationManager
                .getProperty("webui.browse.thumbnail.linkbehaviour");

        if ("bitstream".equals(linkBehaviour))
        {
            linkToBitstream = true;
        }
    }

    /*
     * Get the (X)HTML width and height attributes. As the browser is being used
     * for scaling, we only scale down otherwise we'll get hideously chunky
     * images. This means the media filter should be run with the maxheight and
     * maxwidth set greater than or equal to the size of the images required in
     * the search/browse
     */
    private String getScalingAttr(HttpServletRequest hrq, Bitstream bitstream)
            throws JspException
    {
        BufferedImage buf;

        try
        {
            Context c = UIUtil.obtainContext(hrq);

            InputStream is = BitstreamStorageManager.retrieve(c, bitstream
                    .getID());

            //AuthorizeManager.authorizeAction(bContext, this, Constants.READ);
            // 	read in bitstream's image
            buf = ImageIO.read(is);
            is.close();
        }
        catch (SQLException sqle)
        {
            throw new JspException(sqle.getMessage(), sqle);
        }
        catch (IOException ioe)
        {
            throw new JspException(ioe.getMessage(), ioe);
        }

        // now get the image dimensions
        float xsize = (float) buf.getWidth(null);
        float ysize = (float) buf.getHeight(null);

        // scale by x first if needed
        if (xsize > (float) thumbItemListMaxWidth)
        {
            // calculate scaling factor so that xsize * scale = new size (max)
            float scale_factor = (float) thumbItemListMaxWidth / xsize;

            // now reduce x size and y size
            xsize = xsize * scale_factor;
            ysize = ysize * scale_factor;
        }

        // scale by y if needed
        if (ysize > (float) thumbItemListMaxHeight)
        {
            float scale_factor = (float) thumbItemListMaxHeight / ysize;

            // now reduce x size
            // and y size
            xsize = xsize * scale_factor;
            ysize = ysize * scale_factor;
        }

        StringBuffer sb = new StringBuffer("width=\"").append(xsize).append(
                "\" height=\"").append(ysize).append("\"");

        return sb.toString();
    }

    /* generate the (X)HTML required to show the thumbnail */
    private String getThumbMarkup(HttpServletRequest hrq, Item item)
            throws JspException
    {
        try
        {
            Context c = UIUtil.obtainContext(hrq);
            Thumbnail thumbnail = ItemService.getThumbnail(c, item.getID(), linkToBitstream);

            if (thumbnail == null)
            {
                return "";
            }
            StringBuffer thumbFrag = new StringBuffer();

            if (linkToBitstream)
            {
                Bitstream original = thumbnail.getOriginal();
                String link = hrq.getContextPath() + "/bitstream/" + item.getHandle() + "/" + original.getSequenceID() + "/" +
                                UIUtil.encodeBitstreamName(original.getName(), Constants.DEFAULT_ENCODING);
                thumbFrag.append("<a target=\"_blank\" href=\"" + link + "\" />");
            }
            else
            {
                String link = hrq.getContextPath() + "/handle/" + item.getHandle();
                thumbFrag.append("<a href=\"" + link + "\" />");
            }

            Bitstream thumb = thumbnail.getThumb();
            String img = hrq.getContextPath() + "/retrieve/" + thumb.getID() + "/" +
                        UIUtil.encodeBitstreamName(thumb.getName(), Constants.DEFAULT_ENCODING);
            String alt = thumb.getName();
            String scAttr = getScalingAttr(hrq, thumb);
            thumbFrag.append("<img src=\"")
                    .append(img)
                    .append("\" alt=\"").append(alt).append("\" ")
                     .append(scAttr)
                     .append("/ border=\"0\"></a>");

            return thumbFrag.toString();
        }
        catch (SQLException sqle)
        {
            throw new JspException(sqle.getMessage(), sqle);
        }
        catch (UnsupportedEncodingException e)
        {
            throw new JspException("Server does not support DSpace's default encoding. ", e);
        }
	}
    }
