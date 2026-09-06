package com.testmobile.backend.service;

import com.testmobile.backend.model.CartItem;
import com.testmobile.backend.model.Order;
import com.testmobile.backend.model.OrderItem;
import com.testmobile.backend.repository.CartRepository;
import com.testmobile.backend.repository.OrderRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Service
public class OrderService {

private final OrderRepository orderRepository;
private final CartRepository cartRepository;

public OrderService(
        OrderRepository orderRepository,
        CartRepository cartRepository) {

    this.orderRepository = orderRepository;
    this.cartRepository = cartRepository;
}

// =========================================================
// CUSTOMER CHECKOUT
// =========================================================

@Transactional
public Order checkout(String email) {

    List<CartItem> cartItems =
            cartRepository.findByEmailOrderByIdAsc(email);

    if (cartItems.isEmpty()) {
        throw new RuntimeException("Cart is empty");
    }

    BigDecimal total = BigDecimal.ZERO;

    for (CartItem cartItem : cartItems) {

        BigDecimal price =
                cartItem.getFood().getPrice();

        BigDecimal subtotal =
                price.multiply(
                        BigDecimal.valueOf(
                                cartItem.getQuantity()
                        )
                );

        total = total.add(subtotal);
    }

    Order order = new Order(
            email,
            total.doubleValue(),
            "PLACED",
            LocalDateTime.now()
    );

    for (CartItem cartItem : cartItems) {

        BigDecimal price =
                cartItem.getFood().getPrice();

        BigDecimal subtotal =
                price.multiply(
                        BigDecimal.valueOf(
                                cartItem.getQuantity()
                        )
                );

        OrderItem orderItem =
                new OrderItem(
                        cartItem.getFood().getId(),
                        cartItem.getFood().getName(),
                        price.doubleValue(),
                        cartItem.getQuantity(),
                        subtotal.doubleValue()
                );

        order.addItem(orderItem);
    }

    Order savedOrder =
            orderRepository.save(order);

    cartRepository.deleteByEmail(email);

    return savedOrder;
}

// =========================================================
// CUSTOMER - GET ORDERS
// =========================================================

public List<Order> getOrders(String email) {

    return orderRepository
            .findByEmailOrderByCreatedAtDesc(email);
}

// =========================================================
// ADMIN - GET ALL ORDERS
// =========================================================

public List<Order> getAllOrders() {

    return orderRepository
            .findAllByOrderByCreatedAtDesc();
}

// =========================================================
// GET SINGLE ORDER
// =========================================================

public Order getOrder(Long id) {

    return orderRepository
            .findById(id)
            .orElseThrow(() ->
                    new RuntimeException(
                            "Order not found: " + id
                    )
            );
}


}
