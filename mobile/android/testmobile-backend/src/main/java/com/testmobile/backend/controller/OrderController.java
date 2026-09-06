package com.testmobile.backend.controller;

import com.testmobile.backend.model.Order;
import com.testmobile.backend.service.OrderService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/orders")
@CrossOrigin(origins = "*")
public class OrderController {

    private final OrderService orderService;

    public OrderController(OrderService orderService) {
        this.orderService = orderService;
    }

    @PostMapping("/checkout")
    public ResponseEntity<Order> checkout(
            @RequestParam String email) {

        return ResponseEntity.ok(
                orderService.checkout(email)
        );
    }

    @GetMapping
    public ResponseEntity<List<Order>> getOrders(
            @RequestParam String email) {

        return ResponseEntity.ok(
                orderService.getOrders(email)
        );
    }

    @GetMapping("/{id}")
    public ResponseEntity<Order> getOrder(
            @PathVariable Long id) {

        return ResponseEntity.ok(
                orderService.getOrder(id)
        );
    }
}
