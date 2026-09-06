package com.testmobile.backend.controller;

import com.testmobile.backend.model.Food;
import com.testmobile.backend.service.FoodService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@RestController
@RequestMapping("/api/tab1/food")
@CrossOrigin(origins = "*")
public class FoodController {

    private final FoodService service;

    public FoodController(FoodService service) {
        this.service = service;
    }

    // =========================================================
    // GET ALL FOOD
    // =========================================================

    @GetMapping
    public List<Food> getAll(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size
    ) {

        return service.getAll(page, size);
    }

    // =========================================================
    // GET FOOD BY ID
    // =========================================================

    @GetMapping("/{id}")
    public Food getById(
            @PathVariable Long id
    ) {

        return service.getById(id)
                .orElseThrow(() ->
                        new RuntimeException(
                                "Food not found: " + id
                        )
                );
    }

    // =========================================================
    // CREATE FOOD
    // =========================================================

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public Food create(
            @Valid @RequestBody Food food
    ) {

        return service.create(food);
    }

    // =========================================================
    // UPDATE FOOD
    // =========================================================

    @PutMapping("/{id}")
    public Food update(
            @PathVariable Long id,
            @Valid @RequestBody Food food
    ) {

        return service.update(id, food);
    }

    // =========================================================
    // UPLOAD FOOD IMAGE
    //
    // POST
    // /api/tab1/food/{id}/image
    //
    // multipart field name:
    // image
    // =========================================================

    @PostMapping(
            value = "/{id}/image",
            consumes = "multipart/form-data"
    )
    public Food uploadImage(
            @PathVariable Long id,
            @RequestParam("image") MultipartFile image
    ) {

        return service.uploadImage(
                id,
                image
        );
    }

    // =========================================================
    // DELETE FOOD
    // =========================================================

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(
            @PathVariable Long id
    ) {

        service.delete(id);
    }
}
