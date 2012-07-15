<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%@page import="org.dspace.content.Collection"%>
<%@page import="org.dspace.content.DCDate"%>
<%@page import="java.net.URLEncoder"%>
<%@page import="org.dspace.content.DCValue"%>
<%@page import="org.dspace.content.Item"%>
<%@page import="org.dspace.app.webui.components.RecentSubmissions"%>
<%--
  - Home page JSP
  -
  - Attributes:
  -    communities - Community[] all communities in DSpace
--%>

<%@ page contentType="text/html;charset=UTF-8" %>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>

<%@ page import="java.io.File" %>
<%@ page import="java.util.Enumeration"%>
<%@ page import="java.util.Locale"%>
<%@ page import="javax.servlet.jsp.jstl.core.*" %>
<%@ page import="javax.servlet.jsp.jstl.fmt.LocaleSupport" %>
<%@ page import="org.dspace.core.I18nUtil" %>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>
<%@ page import="org.dspace.content.Community" %>
<%@ page import="org.dspace.core.ConfigurationManager" %>
<%@ page import="org.dspace.browse.ItemCounter" %>

<%
    Community[] communities = (Community[]) request.getAttribute("communities");

    Locale[] supportedLocales = I18nUtil.getSupportedLocales();
    Locale sessionLocale = UIUtil.getSessionLocale(request);
    Config.set(request.getSession(), Config.FMT_LOCALE, sessionLocale);
    String topNews = ConfigurationManager.readNewsFile(LocaleSupport.getLocalizedMessage(pageContext, "news-top.html"));
    String sideNews = ConfigurationManager.readNewsFile(LocaleSupport.getLocalizedMessage(pageContext, "news-side.html"));
    String adventiseNews = ConfigurationManager.readNewsFile(LocaleSupport.getLocalizedMessage(pageContext, "news-adventise.html"));

    ItemCounter ic = new ItemCounter(UIUtil.obtainContext(request));
%>

<dspace:layout locbar="nolink" titlekey="jsp.home.title">
    <!--    <div class="div_top_new">
    <%//= topNews%>
</div>-->
    <div class="div_toppage_content">
        <%
            if (communities.length != 0) {
                int num_row = (int) communities.length / 2;
        %>
        <div class="div_list_community">
            <ul class="ul_community">
                <%

                    for (int i = 0; i < num_row; i++) {%>  
                <li class="li_community">
                    <a href="<%= request.getContextPath()%>/handle/<%= communities[i].getHandle()%>"><%= communities[i].getMetadata("name")%></a>
                    <%
                        if (ConfigurationManager.getBooleanProperty("webui.strengths.show")) {
                    %>
                    <!--<span class="count">[<%//= ic.getCount(communities[i])%>]</span> -->
                    <%
                        }

                    %>
                <li>
                    <%
                        }
                    %>
            </ul>
        </div>
        <div class="div_list_community">
            <ul class="ul_community">
                <%

                    for (int i = num_row; i < communities.length; i++) {%>  
                <li class="li_community">
                    <a href="<%= request.getContextPath()%>/handle/<%= communities[i].getHandle()%>"><%= communities[i].getMetadata("name")%></a>
                    <%
                        if (ConfigurationManager.getBooleanProperty("webui.strengths.show")) {
                    %>
                    <!--span class="count">[<%//= ic.getCount(communities[i])%>]</span-->
                    <%
                        }

                    %>
                <li>
                    <%
                        }
                    %>
            </ul>
        </div>
        <%
            }
        %>
    </div>
    <div class="div_vnpt_event">
        <img src="<%= request.getContextPath()%>/image/QCMobifone.jpg" width="230"/>
    </div>
    <div class="clearall"></div>
    <div class="div_top_new">
        <%= topNews%>
    </div>
    <div class="clearall"></div>
    <%-- Recently Submitted items --%>
    <div class="div_home_content">
        <h3><img  class="nav_home_h3" src="<%= request.getContextPath()%>/image/document_new.png"/><fmt:message key="jsp.community-home.recentsub"/><a href="<%= request.getContextPath()%>/browse?type=dateaccessioned" class="a_recentItem_more">Xem thêm<img  class="image_recentitem_more" src="./image/transparent.gif"/></a></h3>
                <%
                    RecentSubmissions rs = (RecentSubmissions) request.getAttribute("recently.submitted");
                    if (rs != null) {
                        Item[] items = rs.getRecentSubmissions();
                        for (int i = 0; i < items.length; i++) {
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
                            
                            DCValue[] dateissued = items[i].getMetadata("dc", "date", "issued", Item.ANY);
                            String dateissuedval = "";
                            if (dateissued != null) {
                                if (dateissued.length > 0) {
                                    dateissuedval = dateissued[0].value;
            //                        DCDate dateissuedvaldate = new DCDate(dateissuedval);
            //                        dateissuedval = UIUtil.displayDate(dateissuedvaldate, true, true, (HttpServletRequest)pageContext.getRequest());
                                }
                            }
                            DCValue[] dcauthor = items[i].getMetadata("dc", "contributor", "author", Item.ANY);
                            String authorval = "";
                            if (dcauthor != null) {
                                if (dcauthor.length > 0) {
                                    authorval = dcauthor[0].value;
                                }
                            }
                            DCDate dateaccesionval = new DCDate(items[i].getLastModified());
                            Collection[] collections = items[i].getCollections();
                %>
                    <div class="div_recent_item">
                        <p class="recentItem">
                        <img  class="a_recentitem" src="<%= request.getContextPath()%>/image/transparent.gif"/>
                        <a class="a_item_title" href="<%= request.getContextPath()%>/handle/<%= items[i].getHandle()%>"><%= displayTitle%></a>
                        <span class="span_date_right"><dspace:date date="<%= dateaccesionval %>" /></span>
                        </p>
                        <p class="dc_description">
                            <%=description%>
                        </p>
                        <p class='info_preview'>
                        <%  for (int j = 0; j < collections.length; j++) { %>
                                                        <a href="<%= request.getContextPath() %>/handle/<%= collections[j].getHandle() %>"><%= collections[j].getMetadata("name") %></a>
                                    <%  } %>
                        <% if(!"".equals(authorval)){ %>
                            &nbsp;-&nbsp;Tác giả: <span><%=authorval%></span>
                        <%}%>
                        <% if(!"".equals(dateissuedval)){ %>
                            &nbsp;-&nbsp;Xuất bản: <span><%=dateissuedval%></span>
                        <%}%>
                        </p>
                    </div>
                    <%
                            }
                        }
                    %>
        <div class="div_box_subbar_content_footer"></div>
    </div>
    <%-- Recently Submitted items --%>
    <div class="div_box_subbar fl">
        <h3><img  class="nav_home_h3" src="<%= request.getContextPath()%>/image/author.png"/>Các tác giả<a href="<%= request.getContextPath()%>/browse?type=author" class="a_recentItem_more">Xem thêm<img  class="image_recentitem_more" src="./image/transparent.gif"/></a></h3>
        <div class="div_box_subbar_content">
                <%
                    // prepare the next and previous links
                    String linkBase = request.getContextPath() + "/";
                    String sharedLink = linkBase + "browse?type=" + URLEncoder.encode("author");
                    // Row: toggles between Odd and Even
                    String[][] results = (String[][]) request.getAttribute("recently.submitted.author");

                    for (int i = 0; i < results.length; i++) {
                %>
        <p class="recentItem"><img  class="a_recentauthor" src="<%= request.getContextPath()%>/image/transparent.gif"/><a href="<%= sharedLink%><% if (results[i][1] != null) {%>&amp;authority=<%= URLEncoder.encode(results[i][1], "UTF-8")%>">results[i][0]%></a> <% } else {%>&amp;value=<%= URLEncoder.encode(results[i][0], "UTF-8")%>"><%= results[i][0]%></a> <% }%></p>
            <%
                }
            %>
        <div class="div_box_subbar_content_footer"></div>
        </div>
    </div>
    <%-- Recently Submitted items --%>
    <div class="div_box_subbar fr">
        <h3><img  class="nav_home_h3" src="<%= request.getContextPath()%>/image/subject.png"/>Các chủ đề<a href="<%= request.getContextPath()%>/browse?type=subject" class="a_recentItem_more">Xem thêm<img  class="image_recentitem_more" src="./image/transparent.gif"/></a></h3>
        <div class="div_box_subbar_content">
                <%
                    sharedLink = linkBase + "browse?type=" + URLEncoder.encode("subject");
                    // Row: toggles between Odd and Even
                    String[][] subjectresults = (String[][]) request.getAttribute("recently.submitted.subject");

                    for (int i = 0; i < subjectresults.length; i++) {
                %>
        <p class="recentItem"><img  class="a_recentsubject" src="<%= request.getContextPath()%>/image/transparent.gif"/><a href="<%= sharedLink%><% if (subjectresults[i][1] != null) {%>&amp;authority=<%= URLEncoder.encode(subjectresults[i][1], "UTF-8")%>">subjectresults[i][0]%></a> <% } else {%>&amp;value=<%= URLEncoder.encode(subjectresults[i][0], "UTF-8")%>"><%= subjectresults[i][0]%></a> <% }%></p>
            <%
                }
            %>
        <div class="div_box_subbar_content_footer"></div>
        </div>
    </div>
    <dspace:sidebar>
        <%= sideNews%>
        <div class="div_box_rightbar">
            <h3><img  class="nav_home_h3" src="<%= request.getContextPath()%>/image/document_good.png"/>Tài liệu nhiều người dùng </h3>
                <%
                    RecentSubmissions rsdateissued = (RecentSubmissions) request.getAttribute("recently.submitted.dateissued");
                    if (rsdateissued != null) {
                        Item[] items = rsdateissued.getRecentSubmissions();
                        for (int i = 0; i < items.length; i++) {
                            DCValue[] dcv = items[i].getMetadata("dc", "title", null, Item.ANY);
                            String displayTitle = "Untitled";
                            if (dcv != null) {
                                if (dcv.length > 0) {
                                    displayTitle = dcv[0].value;
                                }
                            }
                %><p class="recentItem">
                <img  class="a_recentitem_toppage" src="<%= request.getContextPath()%>/image/transparent.gif"/>
                <a href="<%= request.getContextPath()%>/handle/<%= items[i].getHandle()%>"><%= displayTitle%></a></p><%
                        }
                    }
                %>
        </div>
        <div class="div_box_rightbar">
            <h3><img  class="nav_home_h3" src="<%= request.getContextPath()%>/image/document_good.png"/>Quảng cáo</h3>
            <%= adventiseNews%>
        </div>
    </dspace:sidebar>
</dspace:layout>
