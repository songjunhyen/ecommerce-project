package com.example.demo.dao;

import org.apache.ibatis.annotations.*;

import com.example.demo.vo.NonMemberPurchaseInfo;
import com.example.demo.vo.PaymentInfo;
import com.example.demo.vo.PurchaseInfo;

@Mapper
public interface PurchaseDao {

	@Insert("""
        INSERT INTO PurchaseRecords (order_number, userid, cartids, product_id, productids, quantity, optionin, created_at)
        VALUES (#{orderNumber}, #{userid}, #{cartids}, #{productid}, #{productids}, #{quantity}, #{sizecolor}, #{requestDate})
    """)
	void requestPurchase(PurchaseInfo pinfo);

	@Insert("""
        INSERT INTO GuestPurchaseRecords (order_number, product_id, productids, productname, quantity, optionin, created_at, guest_name, guest_email, guest_phone, guest_address)
        VALUES (#{orderNumber}, #{productid}, #{productids}, #{productname}, #{quantity}, #{sizecolor}, #{requestDate}, #{guestName}, #{email}, #{phonenum}, #{guestAddress})
    """)
	void nonmemreqPurchase(NonMemberPurchaseInfo nPinfo);

	@Select("""
        SELECT COUNT(*) FROM PurchaseRecords WHERE order_number = #{orderNumber}
    """)
	int countPurchaseByOrderNumber(String orderNumber);

	@Select("""
        SELECT COUNT(*) FROM GuestPurchaseRecords WHERE order_number = #{orderNumber}
    """)
	int countGuestPurchaseByOrderNumber(String orderNumber);

	@Select("""
        SELECT COUNT(*) FROM PurchaseRecords WHERE order_number = #{orderNumber}
    """)
	int countMemberOrders(String orderNumber);

	@Select("""
        SELECT COUNT(*) FROM GuestPurchaseRecords WHERE order_number = #{orderNumber}
    """)
	int countNonMemberOrders(String orderNumber);

	@Select("""
        SELECT * FROM PurchaseRecords WHERE order_number = #{orderNumber}
    """)
	PurchaseInfo getOrderInfoByPInfo(String orderNumber);

	@Select("""
        SELECT * FROM GuestPurchaseRecords WHERE order_number = #{orderNumber}
    """)
	NonMemberPurchaseInfo getOrderInfoByNInfo(String orderNumber);

	@Select("""
        SELECT payment_status FROM PaymentRecords WHERE order_number = #{orderNumber}
    """)
	String getPaymentStatus(String orderNumber);

	@Select("""
        SELECT COUNT(*) FROM PaymentRecords WHERE order_number = #{orderNumber}
    """)
	int getPayment(String orderNumber);

	@Update("""
        UPDATE PaymentRecords
        SET payment_status = 'completed', payment_date = CURRENT_TIMESTAMP
        WHERE order_number = #{orderNumber}
    """)
	void updateStatus(String orderNumber);

	@Insert("""
        INSERT INTO PaymentRecords (order_number, price, payment_method, payment_status, payment_date)
        VALUES (#{orderNumber}, #{price}, #{paymentMethod}, #{paymentStatus}, #{paymentDate})
    """)
	void insertStatus(PaymentInfo paymentInfo);

	@Select("""
        SELECT name FROM product WHERE id = #{pid}
    """)
	String getproductname(int pid);

	@Select("""
        SELECT productname FROM cart WHERE id = #{firstCartId}
    """)
	String getproductnamebyC(int firstCartId);

	@Select("""
        SELECT email FROM user WHERE userid = #{userId}
    """)
	String getemail(String userId);

	@Select("""
        SELECT productid FROM cart WHERE id = #{cartId}
    """)
	String getproductidbyC(String cartId);

	@Select("""
        SELECT COUNT(*) FROM PurchaseRecords WHERE order_number = #{ordernumber}
    """)
	int isMember(String ordernumber);

	@Select("""
        SELECT COUNT(*) FROM GuestPurchaseRecords WHERE order_number = #{ordernumber}
    """)
	int isNonmember(String ordernumber);

	@Select("""
        SELECT * FROM PurchaseRecords WHERE order_number = #{ordernumber}
    """)
	PurchaseInfo getmember(String ordernumber);

	@Select("""
        SELECT * FROM GuestPurchaseRecords WHERE order_number = #{ordernumber}
    """)
	NonMemberPurchaseInfo getnonmem(String ordernumber);

	@Delete("""
        DELETE FROM cart WHERE id = #{cartid}
    """)
	void delcartid(int cartid);
}
