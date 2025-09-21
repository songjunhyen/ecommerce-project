package com.example.demo.dao;

import org.apache.ibatis.annotations.*;

import com.example.demo.vo.PaymentInfo;

@Mapper
public interface PaymentDao {

	@Update("""
        UPDATE PaymentRecords
        SET imp_uid = #{impUid}
        WHERE order_number = #{merchantUid}
        """)
	void setImpUid(@Param("impUid") String impUid, @Param("merchantUid") String merchantUid);

	@Update("""
        UPDATE PaymentRecords
        SET payment_status = 'ERROR'
        WHERE imp_uid = #{impUid}
        """)
	void removePayAuth(@Param("impUid") String impUid);

	@Update("""
        UPDATE PaymentRecords
        SET payment_status = 'COMPLETED',
            payment_method = #{paymentInfo.paymentMethod},
            payment_date = NOW()
        WHERE order_number = #{merchantUid}
        """)
	void completePayment(@Param("merchantUid") String merchantUid,
						 @Param("paymentInfo") PaymentInfo paymentInfo);

	@Select("""
        SELECT
            imp_uid      AS impUid,
            order_number AS orderNumber,
            price        AS price,
            payment_method AS paymentMethod,
            payment_status AS paymentStatus,
            payment_date AS paymentDate
        FROM PaymentRecords
        WHERE imp_uid = #{impUid}
        """)
	PaymentInfo getPaymentInfoByImpUid(@Param("impUid") String impUid);

	@Select("""
        SELECT
            imp_uid      AS impUid,
            order_number AS orderNumber,
            price        AS price,
            payment_method AS paymentMethod,
            payment_status AS paymentStatus,
            payment_date AS paymentDate
        FROM PaymentRecords
        WHERE order_number = #{ordernumber}
        """)
	PaymentInfo getPaymentDATA(@Param("ordernumber") String ordernumber);
}
