﻿<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="View.ascx.cs" Inherits="Christoc.Modules.DnnChat.View" %>
<%@ Register TagPrefix="dnn" Namespace="DotNetNuke.Web.Client.ClientResourceManagement" Assembly="DotNetNuke.Web.Client" %>
<%@ Import Namespace="DotNetNuke.Services.Localization" %>

<dnn:DnnJsInclude runat="server" FilePath="~/desktopmodules/DnnChat/Scripts/jquery.signalR-2.2.0.min.js" Priority="10" />
<dnn:DnnJsInclude runat="server" FilePath="~/signalr/hubs" Priority="100" />


<script type="text/javascript">
    /*knockout setup for user*/
    jQuery(document).ready(function ($) {
        
        var md = new DnnChat($, ko, {
            moduleId:<% = ModuleId %>,
            userId:<%=UserId%>,
            userName:'<%=UserInfo.DisplayName%>',
            startMessage:'<%=StartMessage%>',
            defaultAvatarUrl:'<%=DefaultAvatarUrl%>',
            sendMessageReconnecting:'<%=Localization.GetString("SendMessageReconnecting.Text",LocalResourceFile)%>',
            stateReconnecting:'<%=Localization.GetString("StateReconnecting.Text",LocalResourceFile)%>',
            stateReconnected:'<%=Localization.GetString("StateReconnected.Text",LocalResourceFile)%>',
            stateConnected:'<%=Localization.GetString("StateConnected.Text",LocalResourceFile)%>',
            stateDisconnected:'<%=Localization.GetString("StateDisconnected.Text",LocalResourceFile)%>',
            stateConnectionSlow:'<%=Localization.GetString("StateConnectionSlow.Text",LocalResourceFile)%>',
            emoticonsUrl:'<%= ResolveUrl(ControlPath + "images/emoticons/simple/") %>',
            alreadyInRoom:'<%=Localization.GetString("AlreadyInRoom.Text",LocalResourceFile)%>',
            anonUsersRooms:'<%=Localization.GetString("AnonymousJoinDenied.Text",LocalResourceFile)%>',
            messageMissingRoom: '<%=Localization.GetString("MessageMissingRoom.Text",LocalResourceFile)%>',
            errorSendingMessage:'<%=Localization.GetString("ErrorSendingMessage.Text",LocalResourceFile)%>',
            roomArchiveLink: '<%=EditUrl(string.Empty,string.Empty,"Archive","&roomid=0") %>',
            defaultRoomId:'<%=DefaultRoomId %>',
            roles:'<%=EncryptedRoles%>',
            //todo: we should populate a different messagedeleteconfirm if you don't have permissions to delete
            messageDeleteConfirmation: '<%=Localization.GetString("MessageDeleteConfirm.Text",LocalResourceFile)%>',
            allUsersNotification: '<%=Localization.GetString("AllUsersNotification.Text",LocalResourceFile)%>',
        });
        md.init('#messages');
    });
    
</script>

<div class="LobbyArea dnnClear" id="roomList">

    <div class="ShowRoomListButton dnnPrimaryAction" data-toggle="modal" data-target="#RoomListModal">
        <%=Localization.GetString("showRoomList.text",LocalResourceFile) %>
    </div>
    <div class="modal RoomList" style="display: none;" id="RoomListModal">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
                    <h4 class="modal-title" id="myModalLabel"><%=Localization.GetString("joinARoom.Text",LocalResourceFile) %></h4>
                </div>
                <div class="modal-body">
                    <!-- ko foreach: rooms -->
                    <div data-bind="html:roomName,click:joinRoom" class="RoomListRoom row" data-dismiss="modal">
                    </div>
                    <!-- /ko -->
                </div>
            </div>
        </div>
    </div>
</div>

<div class="ConnectedRoomList container" id="userRoomList">
    <!-- ko foreach: rooms -->
    <div class="ChatRooms">
        <div class="ConnectedRoomTab" data-bind="id:roomName,click:setActiveRoom,css:{activeRoom:roomId == $parent.activeRoom()}">
            <div data-bind="html:roomName" class="ConnectedRoom">
            </div>
            <div data-bind="html:formatCount(awayMessageCount())" class="roomAwayMessageCount"></div>
            <div data-bind="html:formatCount(awayMentionCount())" class="roomAwayMentionCount"></div>

            <div data-bind="click:disconnectRoom" class="RoomClose"></div>
        </div>
    </div>
    <!-- /ko -->
</div>

<div class="RoomContainer container" id="roomView">
    <!-- ko foreach: rooms -->
    <!-- the display of the rooms that a user is connected -->
    <div class="srcWindow row" data-bind="visible:showRoom">
        <div class="col-lg-10 container chatWrap">
            <div class="ChatWindow" data-bind="attr:{id: roomNameId}">
                <!-- ko foreach: messages -->
                <div data-bind="attr:{class:cssName}" class="row">
                    <div class="col-lg-2 MessageAuthor dnnClear">
                        <!-- ko if: authorUserId>0 -->
                        <img data-bind="attr: {src:photoUrl,alt:authorName},click:targetMessageAuthor" class="MessageAuthorPhoto" />
                        <!-- /ko -->
                        <!-- ko if: authorUserId<1 -->
                        <img data-bind="attr: {src:defaultAvatarUrl,alt:authorName},click:targetMessageAuthor" class="MessageAuthorPhoto" />
                        <!-- /ko -->
                        <div data-bind="html:authorName,click:targetMessageAuthor" class="MessageAuthorText"></div>
                    </div>
                    <div data-bind="html:messageText" class="col-lg-9 MessageText "></div>
                    <div data-bind="dateString: messageDate, click:deleteMessage" class=" col-lg-1 MessageTime"></div>
                </div>
                <!-- /ko -->
            </div>
            <input type="text" data-bind="value:newMessageText, hasfocus: textFocus, enterKey: sendMessage" class="msg" />
            <input class="dnnPrimaryAction" type="button" value="<%= Localization.GetString("btnSubmit.Text",LocalResourceFile)%>" data-bind="click:sendMessage" />
        </div>

        <div class="UsersList col-lg-2 container" id="userList">
            <div class="row usersOnline">
                <div class="col-xs-12">
                    <%= Localization.GetString("usersOnline.Text",LocalResourceFile)%><div data-bind="html:userCount" class="dnnRight"></div>
                </div>
            </div>
            <!-- ko foreach: connectionRecords -->
            <div class="ChatUsers row">
                <!-- ko if: userId>0 -->
                <div class="col-xs-12">
                    <img data-bind="attr: {src:photoUrl},click:targetMessageAuthor" class="UserListPhoto" /><div data-bind="    html:authorName,click:targetMessageAuthor" class="UserListUser UserLoggedIn"></div>
                </div>
                <!-- /ko -->
                <!-- ko if: userId<1 -->
                <div data-bind="html:authorName,click:targetMessageAuthor" class="UserListUser UserNotLoggedIn col-xs-12">
                </div>
                <!-- /ko -->
            </div>
            <!-- /ko -->


        </div>


    </div>
    
    
    <div><a data-bind="attr:{href: roomArchiveLink}" target="_blank"><%=Localization.GetString("Archives.Text",LocalResourceFile) %></a></div>
    <!-- /ko -->
</div>
<div class="container">
    <div class="row">
        <div id="ChatStatus" class="chatStatus col-lg-12">
        </div>
    </div>
    <div class="projectMessage"><%= Localization.GetString("ProjectMessage.Text",LocalResourceFile)%></div>
</div>

