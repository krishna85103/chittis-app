package com.testmobile.backend.model;

import jakarta.persistence.*;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;

@Entity
@Table(name = "food")
public class Food {

    // =========================================================
    // ID
    // =========================================================

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // =========================================================
    // NAME
    // =========================================================

    @NotBlank(message = "Food name is required")
    @Column(nullable = false)
    private String name;

    // =========================================================
    // DESCRIPTION
    // =========================================================

    @NotBlank(message = "Food description is required")
    @Column(nullable = false)
    private String description;

    // =========================================================
    // PRICE
    // =========================================================

    @NotNull(message = "Food price is required")
    @DecimalMin(
            value = "0.0",
            inclusive = true,
            message = "Price cannot be negative"
    )
    @Column(nullable = false, precision = 10, scale = 2)
    private BigDecimal price;

    // =========================================================
    // IMAGE URL
    // =========================================================

    @Column(name = "image_url")
    private String imageUrl;

    // =========================================================
    // CONSTRUCTORS
    // =========================================================

    public Food() {
    }

    public Food(
            String name,
            String description,
            BigDecimal price,
            String imageUrl
    ) {
        this.name = name;
        this.description = description;
        this.price = price;
        this.imageUrl = imageUrl;
    }

    // =========================================================
    // GETTERS
    // =========================================================

    public Long getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public String getDescription() {
        return description;
    }

    public BigDecimal getPrice() {
        return price;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    // =========================================================
    // SETTERS
    // =========================================================

    public void setId(Long id) {
        this.id = id;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public void setPrice(BigDecimal price) {
        this.price = price;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    // =========================================================
    // TO STRING
    // =========================================================

    @Override
    public String toString() {
        return "Food{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", description='" + description + '\'' +
                ", price=" + price +
                ", imageUrl='" + imageUrl + '\'' +
                '}';
    }
}
