<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    // Taking the Default User as Initial Primary Key (1000), since there is no login page
    session.setAttribute("uid",1000);
    int defaultUserId = (Integer) session.getAttribute("uid");

    // registering the driver class
    Class.forName("com.mysql.jdbc.Driver");
    // establishing the connection
    Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/MyOnlineBanking","username","password");

    Statement st = con.createStatement();
    PreparedStatement pst;
    ResultSet rs;
%>

<%
    // This if statement, is used to handle Fund Transfer Request in POST Method.
    if(request.getMethod().equals("POST"))
    {
        // getting the from and to details from session and request.
        int from = (Integer) session.getAttribute("uid");
        int to = Integer.valueOf(request.getParameter("to"));

        // checking whether the Recipient Exists in the User Database.
        pst = con.prepareStatement("select * from account_holders where acc_no=?");
        pst.setInt(1,to);

        rs = pst.executeQuery();

        // if user exists, then continue the transaction
        if(rs.next())
        {
            // checking whether the sender has enough amount in his Account, and reducing his Account Balance
            int res1 = st.executeUpdate("update account_holders set balance=balance-1000 where acc_no="+from+" and balance>=1000");

            // if the above statement executed, continue with the Remaining Transaction.
            if(res1==1)
            {
                // setting the Default Amount of 1000 rs as stated in mail.
                int cash = 1000;

                // Increasing the Account Balance of Receiver
                st.executeUpdate("update  account_holders set balance=balance+1000 where acc_no="+to);

                // Inserting the transaction into the database
                st.executeUpdate("insert into transactions(sender_account_no,receiver_account_no,amount) values("+from+","+to+","+cash+")");

            }
            else
            {
                // if user don't have enough balance, alerting the Sender
                out.print("<script> alert('You dont have Enough Balance in your Account.'); </script>");
            }
        }
        else
        {
            // If the Receiver Account Doesn't Exist in the Database, Alerting the Sender
            out.print("<script> alert('Sorry Account No Doesnt Exist.'); </script>");
        }
    }
%>


<html>
<head>

    <style>
        body
        {
            font-family: sans-serif;
        }
        .heading1
        {
            text-align: center;
            color: #3c3131;
            margin-top: 30px;
        }
        table
        {
            margin-left: 20%;
        }
        th
        {
            width: 25%;
            color : #3c3131;
            background-color: #bbbbbb;
            font-weight: bold;
            text-align: center;
            padding: 5px;
        }
        td
        {
            width: 25%;
            background-color: #eeeeee;
            text-align: center;
            padding: 5px;
        }
        tr pre
        {
            font-family: Bahnschrift;
            display: inline;
        }
        #to
        {
            width : 50%;
            margin-left: 25%;
            padding: 10px;
            border: 3px solid #3c3131;
            opacity: 0.8;
            border-radius: 5px;
            box-shadow: none;
        }
        #transfer
        {
            display: block;
            width: 15%;
            color : #dddddd;
            background-color: #3c3131;
            padding : 8px;
            margin-left: 42.5%;
            border-radius: 5px;
            font-weight: bolder;
            font-size: 1.1rem;
            cursor: pointer;
            opacity: 0.9;
        }
    </style>

</head>
<body>

    <%
        // Querying the User Details.
        rs = st.executeQuery("select * from account_holders where acc_no="+defaultUserId);
        while(rs.next())
        {
    %>

    <span style="font-size: 35px;text-align: center;color: brown;display: block;margin-bottom: 25px;text-decoration: underline">Account Page</span>

    <%-- User details --%>
    <h2 style="margin-left: 20%;color: orangered;display: inline;">Welcome, <span style="color: #3c3131"><% out.print(rs.getString("name")); %></span></h2>
    <h2 style="margin-left: 25%;color: orangered;display: inline;">Balance Available : <span style="color: #3c3131"><% out.print(rs.getInt("balance")); %> rs</span></h2>
    <%
        }
    %>

    <h2 class="heading1">Your Previous Transactions</h2>
    <table width="60%">
        <tr>
            <th>From</th>
            <th>To</th>
            <th>Amount</th>
            <th>Date & Time</th>
        </tr>
        <%
            // Querying the Previous Transactions.
            rs = st.executeQuery("select * from transactions where sender_account_no="+defaultUserId+" or receiver_account_no="+defaultUserId+" order by trans_date desc limit 5");
            // This stat is used, Whether the Transactions available or not
            boolean stat = false;
            while(rs.next())
            {
        %>

        <%-- Setting the Transaction Details. --%>
        <tr>
            <td><% out.print(rs.getInt("sender_account_no")); %></td>
            <td><% out.print(rs.getInt("receiver_account_no")); %></td>
            <td><% out.print(rs.getInt("amount")); %></td>
            <td><%
                // Displaying date in pretty Format
                Date dt = new Date(rs.getTimestamp("trans_date").getTime());
                SimpleDateFormat simpleDateFormat = new SimpleDateFormat("dd-MM-yy    HH:mm:ss  a");
                out.print("<pre>"+simpleDateFormat.format(dt)+"<pre>");
            %></td>
        </tr>
        <%
                // if transactions exist, This Stat Becomes true
                stat = true;
            }
        %>

        <%
            // if stat is false, Then there are no Transactions
            if(!stat)
            {
        %>
        <tr>
            <td colspan="4"><p>You do not have any Transactions</p></td>
        </tr>
        <%
            }

            con.close();
        %>

    </table>

    <span style="display: block;margin-top: 40px;text-align: center;color: #3c3131;font-size: 30px;">Fund Transfer</span>
    <%-- This Form is used to send the Receiver Account no, to the Server in POST Method--%>
    <%-- Data is sent to Same JSP Page, And We Already had Written Code Above to handle this Request --%>
    <form action="UserAccountPage.jsp" method="post" id="transferForm">
        <input type="number" name="to" id="to" placeholder="Enter Account No. of the Recipient" required />

        <button id="transfer" style="margin-top: 3px">Transfer Amount</button>
    </form>

</body>

</html>
