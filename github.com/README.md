The pb.go file is initially generated and placed in a temporary directory by
the protoc command. This temporary location allows for a controlled comparison
between the newly generated pb.go file and the existing one to detect any
differences or "drift." After verifying that the generated file matches the
expected output, it is then moved to its final location, which is in the same
directory as the corresponding .proto file.

This approach ensures consistency and helps catch any unintended changes in the
generated code before it's finalized in the repository.
