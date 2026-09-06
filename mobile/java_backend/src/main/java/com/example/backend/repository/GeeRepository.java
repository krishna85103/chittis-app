package com.example.backend.repository;

import com.example.backend.model.Gee;
import org.springframework.data.jpa.repository.JpaRepository;

public interface GeeRepository extends JpaRepository<Gee, Long> {
}
