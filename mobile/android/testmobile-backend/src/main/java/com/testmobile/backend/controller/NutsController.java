package com.testmobile.backend.controller;

import com.testmobile.backend.model.Nuts;
import com.testmobile.backend.service.NutsService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/tab1/nuts")
@CrossOrigin(origins = "*")
public class NutsController {

    private final NutsService service;

    public NutsController(NutsService service) {
        this.service = service;
    }

    @GetMapping
    public List<Nuts> getAll() {
        return service.getAll();
    }

    @GetMapping("/{id}")
    public Nuts getById(@PathVariable Long id) {
        return service.getById(id)
                .orElseThrow(() ->
                        new RuntimeException("Nuts not found: " + id));
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public Nuts create(@Valid @RequestBody Nuts nuts) {
        return service.create(nuts);
    }

    @PutMapping("/{id}")
    public Nuts update(
            @PathVariable Long id,
            @Valid @RequestBody Nuts nuts) {

        return service.update(id, nuts);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable Long id) {
        service.delete(id);
    }
}
