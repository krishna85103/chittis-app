package com.testmobile.backend.controller;

import com.testmobile.backend.model.CartItem;
import com.testmobile.backend.service.CartService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/cart")
@CrossOrigin(origins = "*")
public class CartController {

    private final CartService cartService;

    public CartController(CartService cartService) {
        this.cartService = cartService;
    }

    @GetMapping
    public ResponseEntity<List<CartItem>> getCart(
            @RequestParam String email) {

        return ResponseEntity.ok(
                cartService.getCart(email)
        );
    }

    @PostMapping
    public ResponseEntity<CartItem> addToCart(
            @RequestParam String email,
            @RequestParam Long foodId,
            @RequestParam(defaultValue = "1") int quantity) {

        return ResponseEntity.ok(
                cartService.addToCart(
                        email,
                        foodId,
                        quantity
                )
        );
    }

    @PutMapping
    public ResponseEntity<CartItem> updateQuantity(
            @RequestParam String email,
            @RequestParam Long foodId,
            @RequestParam int quantity) {

        return ResponseEntity.ok(
                cartService.updateQuantity(
                        email,
                        foodId,
                        quantity
                )
        );
    }

    @DeleteMapping
    public ResponseEntity<Void> removeFromCart(
            @RequestParam String email,
            @RequestParam Long foodId) {

        cartService.removeFromCart(
                email,
                foodId
        );

        return ResponseEntity.noContent().build();
    }

    @DeleteMapping("/clear")
    public ResponseEntity<Void> clearCart(
            @RequestParam String email) {

        cartService.clearCart(email);

        return ResponseEntity.noContent().build();
    }
}
