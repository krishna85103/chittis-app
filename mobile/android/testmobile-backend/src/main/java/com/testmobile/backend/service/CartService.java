package com.testmobile.backend.service;

import com.testmobile.backend.model.CartItem;
import com.testmobile.backend.model.Food;
import com.testmobile.backend.repository.CartRepository;
import com.testmobile.backend.repository.FoodRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CartService {

    private final CartRepository cartRepository;
    private final FoodRepository foodRepository;

    public CartService(
            CartRepository cartRepository,
            FoodRepository foodRepository) {

        this.cartRepository = cartRepository;
        this.foodRepository = foodRepository;
    }

    public List<CartItem> getCart(String email) {
        return cartRepository.findByEmailOrderByIdAsc(email);
    }

    public CartItem addToCart(
            String email,
            Long foodId,
            int quantity) {

        if (quantity <= 0) {
            throw new RuntimeException(
                    "Quantity must be greater than zero"
            );
        }

        Food food = foodRepository.findById(foodId)
                .orElseThrow(() ->
                        new RuntimeException(
                                "Food not found: " + foodId
                        )
                );

        var existing =
                cartRepository.findByEmailAndFood_Id(
                        email,
                        foodId
                );

        if (existing.isPresent()) {
            CartItem item = existing.get();

            item.setQuantity(
                    item.getQuantity() + quantity
            );

            return cartRepository.save(item);
        }

        CartItem item = new CartItem(
                email,
                food,
                quantity
        );

        return cartRepository.save(item);
    }

    public CartItem updateQuantity(
            String email,
            Long foodId,
            int quantity) {

        CartItem item =
                cartRepository.findByEmailAndFood_Id(
                        email,
                        foodId
                ).orElseThrow(() ->
                        new RuntimeException(
                                "Cart item not found"
                        )
                );

        if (quantity <= 0) {
            cartRepository.delete(item);
            return item;
        }

        item.setQuantity(quantity);

        return cartRepository.save(item);
    }

    public void removeFromCart(
            String email,
            Long foodId) {

        cartRepository.deleteByEmailAndFood_Id(
                email,
                foodId
        );
    }

    public void clearCart(String email) {
        cartRepository.deleteByEmail(email);
    }
}
