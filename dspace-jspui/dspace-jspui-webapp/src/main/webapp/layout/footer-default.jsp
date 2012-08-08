<%--

    The contents of this file are subject to the license and copyright
    detailed in the LICENSE and NOTICE files at the root of the source
    tree and available online at

    http://www.dspace.org/license/

--%>
<%--
  - Footer for home page
--%>

<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%@ taglib uri="http://www.dspace.org/dspace-tags.tld" prefix="dspace" %>
<%@ page contentType="text/html;charset=UTF-8" %>

<%@ page import="java.net.URLEncoder" %>
<%@ page import="org.dspace.app.webui.util.UIUtil" %>

<%
    String sidebar = (String) request.getAttribute("dspace.layout.sidebar");
    String rightbar = (String) request.getAttribute("dspace.layout.rightbar");
    String navbar = (String) request.getAttribute("dspace.layout.navbar");
    String uri = (String) request.getRequestURI();
%>
<%-- End of page content --%>
</div>
</div>
<% if (!(navbar.indexOf("admin") > -1)) {%>
<div class="divrightbar">
    <div class="divmargin">
        <%-- Right-hand side bar if appropriate --%>
        <%
            if (uri.indexOf("/home.jsp", 0) == -1) {
        %>

        <dspace:include page="/layout/navigation-default.jsp" />

        <%                        }
        %>
        <%
            if (sidebar != null) {
        %>

        <%= sidebar%>

        <%
            }
        %>
        <%
            if (rightbar != null) {
        %>

        <dspace:include page="<%= rightbar%>" />

        <%
            }
        %>
    </div>
</div>
<%}%>
</div>
<div class="divfooter">
    <%-- Page footer --%>
    <div class="div_box_footer">
        <div class="div_box_footer_intro">
            <p class="footer_title">TẬP ĐOÀN BƯU CHÍNH VIỄN THÔNG VIỆT NAM</p>
            <p>Giấy phép 605/GP - INTER BVHTT - Trưởng ban biên tập: Phan Thao Nguyên</p>
            <p>Đơn vị phát triển: Trung tâm Thông tin và Quan hệ công chúng - 57 Huỳnh Thúc Kháng - Hà Nội</p>
            <p>Mọi thắc mắc xin liên hệ: Nguyễn Tuấn Mạnh - 0915 038 868 - Email: <a href="mailto: manhnt@vnpt.vn" style="color: #666">manhnt@vnpt.vn</a></p>
        </div>
        <div class="div_box_counter">
            <script  >
                var url = window.location.href;
                if(url.charAt(url.length-1) == "/"){
                    unSelected();	 
                    jQuery('.nav-home').parent().attr("class", "current"); 
                }
                if (url.indexOf("category")>-1) {	
                    unSelected();	 
                    jQuery('.nav-community-list').parent().attr("class", "current"); 
                }	 
                if (url.indexOf('dateissued')>-1) {
                    unSelected();
                    jQuery('.nav-dateissued').parent().attr("class", "current"); 
                }
                if (url.indexOf('author')>-1) {
                    unSelected();
                    jQuery('.nav-author').parent().attr("class", "current"); 
                }
                if (url.indexOf('title')>-1) {
                    unSelected();
                    jQuery('.nav-title').parent().attr("class", "current"); 
                }
                if (url.indexOf('subject')>-1) {
                    unSelected();
                    jQuery('.nav-subject').parent().attr("class", "current"); 
                }
                if (url.indexOf('dspace-admin')>-1 || url.indexOf('tools')>-1 || url.indexOf('statistics')>-1) { 
                    unSelected();
                    jQuery('.nav-dspace-admin').parent().attr("class", "current"); 
                }
                function unSelected(){
                    jQuery('#navid li').attr("class", "");
                }
                // config window
                if(jQuery(window).height() - 250 > 600)
                    jQuery('.divcontent').css('min-height', jQuery(window).height() - 250+"px");
                //                            if(jQuery('.divnavbar').html() == null)
                //                            {
                //                                jQuery('.divpagecontent').css('width', jQuery(window).width() - 416+"px");
                //                            }else{
                //                                jQuery('.divpagecontent').css('width', jQuery(window).width() - 291+"px");
                //                            }
            </script>
        </div>
    </div>
</div>
</div>
</body>
</html>