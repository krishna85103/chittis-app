package com.testmobile.backend.service;

import com.testmobile.backend.model.Food;
import com.testmobile.backend.repository.FoodRepository;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
public class FoodService {

    private final FoodRepository foodRepository;

    /*
     * Store uploads using an absolute path.
     *
     * The application runs from /app in the container,
     * therefore this resolves to:
     *
     * /app/uploads/food
     */
    private final Path uploadDirectory =
            Paths.get("uploads", "food")
                    .toAbsolutePath()
                    .normalize();

    public FoodService(FoodRepository foodRepository) {
        this.foodRepository = foodRepository;

        try {
            Files.createDirectories(uploadDirectory);

            System.out.println(
                    "Food upload directory: "
                            + uploadDirectory
            );

        } catch (IOException e) {
            throw new RuntimeException(
                    "Could not create food upload directory",
                    e
            );
        }
    }

    // =========================================================
    // GET ALL FOOD WITH PAGINATION
    // =========================================================

    public List<Food> getAll(int page, int size) {

        if (page < 0) {
            page = 0;
        }

        if (size <= 0) {
            size = 20;
        }

        if (size > 100) {
            size = 100;
        }

        Pageable pageable =
                PageRequest.of(page, size);

        return foodRepository
                .findAll(pageable)
                .getContent();
    }

    // =========================================================
    // GET FOOD BY ID
    // =========================================================

    public Optional<Food> getById(Long id) {
        return foodRepository.findById(id);
    }

    // =========================================================
    // CREATE FOOD
    // =========================================================

    public Food create(Food food) {
        return foodRepository.save(food);
    }

    // =========================================================
    // UPDATE FOOD
    // =========================================================

    public Food update(
            Long id,
            Food food
    ) {

        Food existingFood =
                foodRepository.findById(id)
                        .orElseThrow(() ->
                                new RuntimeException(
                                        "Food not found: " + id
                                )
                        );

        existingFood.setName(
                food.getName()
        );

        existingFood.setDescription(
                food.getDescription()
        );

        existingFood.setPrice(
                food.getPrice()
        );

        /*
         * Only update imageUrl when explicitly supplied.
         *
         * This prevents a normal food update from
         * accidentally removing an existing image.
         */
        if (food.getImageUrl() != null) {
            existingFood.setImageUrl(
                    food.getImageUrl()
            );
        }

        return foodRepository.save(
                existingFood
        );
    }

    // =========================================================
    // UPLOAD FOOD IMAGE
    // =========================================================

    public Food uploadImage(
            Long id,
            MultipartFile file
    ) {

        Food food =
                foodRepository.findById(id)
                        .orElseThrow(() ->
                                new RuntimeException(
                                        "Food not found: " + id
                                )
                        );

        if (file == null || file.isEmpty()) {
            throw new RuntimeException(
                    "Image file is empty"
            );
        }

        String contentType =
                file.getContentType();

        if (contentType == null ||
                !contentType.startsWith("image/")) {

            throw new RuntimeException(
                    "Only image files are allowed"
            );
        }

        String originalName =
                file.getOriginalFilename();

        String extension = "";

        if (originalName != null &&
                originalName.contains(".")) {

            extension =
                    originalName.substring(
                            originalName.lastIndexOf(".")
                    ).toLowerCase();
        }

        /*
         * Generate a unique filename:
         *
         * 2_<uuid>.png
         * 4_<uuid>.jpg
         */
        String filename =
                id + "_" +
                UUID.randomUUID() +
                extension;

        Path target =
                uploadDirectory
                        .resolve(filename)
                        .normalize();

        /*
         * Security check.
         */
        if (!target.startsWith(
                uploadDirectory
        )) {

            throw new RuntimeException(
                    "Invalid file path"
            );
        }

        try {

            /*
             * Make absolutely sure the upload
             * directory exists.
             */
            Files.createDirectories(
                    uploadDirectory
            );

            try (InputStream inputStream =
                         file.getInputStream()) {

                Files.copy(
                        inputStream,
                        target,
                        StandardCopyOption.REPLACE_EXISTING
                );
            }

        } catch (IOException e) {

            throw new RuntimeException(
                    "Failed to save image",
                    e
            );
        }

        /*
         * Delete the previous image only after
         * the new image has been successfully written.
         */
        deleteOldImage(
                food.getImageUrl()
        );

        /*
         * Store only the public URL in the database.
         */
        String imageUrl =
                "/uploads/food/" + filename;

        food.setImageUrl(
                imageUrl
        );

        return foodRepository.save(
                food
        );
    }

    // =========================================================
    // DELETE FOOD
    // =========================================================

    public void delete(Long id) {

        Food food =
                foodRepository.findById(id)
                        .orElseThrow(() ->
                                new RuntimeException(
                                        "Food not found: " + id
                                )
                        );

        deleteOldImage(
                food.getImageUrl()
        );

        foodRepository.delete(
                food
        );
    }

    // =========================================================
    // DELETE OLD IMAGE
    // =========================================================

    private void deleteOldImage(
            String imageUrl
    ) {

        if (imageUrl == null ||
                imageUrl.isBlank()) {

            return;
        }

        if (!imageUrl.startsWith(
                "/uploads/food/"
        )) {

            return;
        }

        String filename =
                imageUrl.substring(
                        "/uploads/food/".length()
                );

        /*
         * Prevent path traversal.
         */
        if (filename.contains("..") ||
                filename.contains("/") ||
                filename.contains("\\")) {

            return;
        }

        Path oldFile =
                uploadDirectory
                        .resolve(filename)
                        .normalize();

        if (!oldFile.startsWith(
                uploadDirectory
        )) {

            return;
        }

        try {

            Files.deleteIfExists(
                    oldFile
            );

        } catch (IOException e) {

            System.err.println(
                    "Could not delete old image: "
                            + e.getMessage()
            );
        }
    }
}
