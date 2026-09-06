package com.example.backend.controller;

import com.example.backend.model.Gee;
import com.example.backend.service.GeeService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/tab1/gee")
@CrossOrigin(origins = "*")
public class GeeController {

    private final GeeService service;

    public GeeController(GeeService service) {
        this.service = service;
    }

    @GetMapping
    public List<Gee> getAll() {
        return service.getAll();
    }

    @GetMapping("/{id}")
    public Gee getById(@PathVariable Long id) {
        return service.getById(id)
                .orElseThrow(() ->
                        new RuntimeException("Gee not found: " + id));
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public Gee create(@Valid @RequestBody Gee gee) {
        return service.create(gee);
    }

    @PutMapping("/{id}")
    public Gee update(
            @PathVariable Long id,
            @Valid @RequestBody Gee gee) {

        return service.update(id, gee);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable Long id) {
        service.delete(id);
    }
}
