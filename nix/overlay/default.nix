self: super: with self;

{

  this = super.this.overrideScope (callPackage ../scope {});

}
