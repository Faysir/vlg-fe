angular.module('vlg')

.value("GameAudioValue", [
  { name: "baofei-1",      path: "vendor/audios/baofei-1.ogg"     }
  { name: "baofei-10",     path: "vendor/audios/baofei-10.ogg"    }
  { name: "baofei-11",     path: "vendor/audios/baofei-11.ogg"    }
  { name: "baofei-12",     path: "vendor/audios/baofei-12.ogg"    }
  { name: "baofei-13",     path: "vendor/audios/baofei-13.ogg"    }
  { name: "baofei-14",     path: "vendor/audios/baofei-14.ogg"    }
  { name: "baofei-15",     path: "vendor/audios/baofei-15.ogg"    }
  { name: "baofei-16",     path: "vendor/audios/baofei-16.ogg"    }
  { name: "baofei-2",      path: "vendor/audios/baofei-2.ogg"     }
  { name: "baofei-3",      path: "vendor/audios/baofei-3.ogg"     }
  { name: "baofei-4",      path: "vendor/audios/baofei-4.ogg"     }
  { name: "baofei-5",      path: "vendor/audios/baofei-5.ogg"     }
  { name: "baofei-6",      path: "vendor/audios/baofei-6.ogg"     }
  { name: "baofei-7",      path: "vendor/audios/baofei-7.ogg"     }
  { name: "baofei-8",      path: "vendor/audios/baofei-8.ogg"     }
  { name: "baofei-9",      path: "vendor/audios/baofei-9.ogg"     }
  { name: "greetings",     path: "vendor/audios/greetings.ogg"    }
  { name: "lastwords",     path: "vendor/audios/lastwords.ogg"    }
  { name: "lastwords-1",   path: "vendor/audios/lastwords-1.ogg"  }
  { name: "lastwords-2",   path: "vendor/audios/lastwords-2.ogg"  }
  { name: "lastwords-3",   path: "vendor/audios/lastwords-3.ogg"  }
#  { name: "lastwords-4",   path: "vendor/audios/lastwords-4.ogg"  }
#  { name: "lastwords-5",   path: "vendor/audios/lastwords-5.ogg"  }
#  { name: "lastwords-6",   path: "vendor/audios/lastwords-6.ogg"  }
#  { name: "lastwords-7",   path: "vendor/audios/lastwords-7.ogg"  }
#  { name: "lastwords-8",   path: "vendor/audios/lastwords-8.ogg"  }
#  { name: "lastwords-9",   path: "vendor/audios/lastwords-9.ogg"  }
#  { name: "lastwords-10",  path: "vendor/audios/lastwords-10.ogg" }
#  { name: "lastwords-11",  path: "vendor/audios/lastwords-11.ogg" }
#  { name: "lastwords-12",  path: "vendor/audios/lastwords-12.ogg" }
#  { name: "lastwords-13",  path: "vendor/audios/lastwords-13.ogg" }
#  { name: "lastwords-14",  path: "vendor/audios/lastwords-14.ogg" }
#  { name: "lastwords-15",  path: "vendor/audios/lastwords-15.ogg" }
#  { name: "lastwords-16",  path: "vendor/audios/lastwords-16.ogg" }
  { name: "mvp",           path: "vendor/audios/mvp.ogg"          }
  { name: "night-comes",   path: "vendor/audios/night-comes.ogg"  }
  { name: "out-1",         path: "vendor/audios/out-1.ogg"        }
  { name: "out-10",        path: "vendor/audios/out-10.ogg"       }
  { name: "out-11",        path: "vendor/audios/out-11.ogg"       }
  { name: "out-12",        path: "vendor/audios/out-12.ogg"       }
  { name: "out-13",        path: "vendor/audios/out-13.ogg"       }
  { name: "out-14",        path: "vendor/audios/out-14.ogg"       }
  { name: "out-15",        path: "vendor/audios/out-15.ogg"       }
  { name: "out-16",        path: "vendor/audios/out-16.ogg"       }
  { name: "out-2",         path: "vendor/audios/out-2.ogg"        }
  { name: "out-3",         path: "vendor/audios/out-3.ogg"        }
  { name: "out-4",         path: "vendor/audios/out-4.ogg"        }
  { name: "out-5",         path: "vendor/audios/out-5.ogg"        }
  { name: "out-6",         path: "vendor/audios/out-6.ogg"        }
  { name: "out-7",         path: "vendor/audios/out-7.ogg"        }
  { name: "out-8",         path: "vendor/audios/out-8.ogg"        }
  { name: "out-9",         path: "vendor/audios/out-9.ogg"        }
  { name: "out-field-pk",  path: "vendor/audios/out-field-pk.ogg" }
  { name: "pk",            path: "vendor/audios/pk.ogg"           }
  { name: "speak-1",       path: "vendor/audios/speak-1.ogg"      }
  { name: "speak-10",      path: "vendor/audios/speak-10.ogg"     }
  { name: "speak-11",      path: "vendor/audios/speak-11.ogg"     }
  { name: "speak-12",      path: "vendor/audios/speak-12.ogg"     }
  { name: "speak-13",      path: "vendor/audios/speak-13.ogg"     }
  { name: "speak-14",      path: "vendor/audios/speak-14.ogg"     }
  { name: "speak-15",      path: "vendor/audios/speak-15.ogg"     }
  { name: "speak-16",      path: "vendor/audios/speak-16.ogg"     }
  { name: "speak-2",       path: "vendor/audios/speak-2.ogg"      }
  { name: "speak-3",       path: "vendor/audios/speak-3.ogg"      }
  { name: "speak-4",       path: "vendor/audios/speak-4.ogg"      }
  { name: "speak-5",       path: "vendor/audios/speak-5.ogg"      }
  { name: "speak-6",       path: "vendor/audios/speak-6.ogg"      }
  { name: "speak-7",       path: "vendor/audios/speak-7.ogg"      }
  { name: "speak-8",       path: "vendor/audios/speak-8.ogg"      }
  { name: "speak-9",       path: "vendor/audios/speak-9.ogg"      }
  { name: "vote",          path: "vendor/audios/vote.ogg"         }
  { name: "win-cops",      path: "vendor/audios/win-cops.ogg"     }
  { name: "win-killers",   path: "vendor/audios/win-killers.ogg"  }
])