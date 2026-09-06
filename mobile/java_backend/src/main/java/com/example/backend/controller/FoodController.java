package com.example.backend.controller;

import com.example.backend.model.Food;
import com.example.backend.service.FoodService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/tab1/food")
@CrossOrigin(origins = "*")
public class FoodController {

    private final FoodService service;

    public FoodController(FoodService service) {
        this.service = service;
    }

    @GetMapping
    public List<Food> getAll() {
        return service.getAll();
    }

    @GetMapping("/{id}")
    public Food getById(@PathVariable Long id) {
        return service.getById(id)
                .orElseThrow(() ->
                        new RuntimeException("Food not found: " + id));
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public Food create(@Valid @RequestBody Food food) {
        return service.create(food);
    }

    @PutMapping("/{id}")
    public Food update(
            @PathVariable Long id,
            @Valid @RequestBody Food food) {

        return service.update(id, food);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable Long id) {
        service.delete(id);
    }
}
